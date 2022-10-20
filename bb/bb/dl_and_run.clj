(ns bb.dl-and-run
  (:require [babashka.tasks :refer [shell]]
            [babashka.curl :as curl]
            [bask.colors :as c]
            [bb.tasks :as t]
            [selmer.parser :refer [<<]]
            [cheshire.core :as json]
            [clojure.edn :as edn]))

(defn- seek [f coll]
  (reduce (fn [_ element] (when-let [resp (f element)] (reduced resp)))
          nil
          coll))

(defn- gh-get [url]
  (try (-> url
           (curl/get {:headers {"Accept" "application/vnd.github+json"
                                "Authorization" (str "Bearer " (t/env "GH_TOKEN"))}})
           :body
           (json/decode true))
       (catch Exception e (throw (ex-info (str "Github GET error.\n" (pr-str e)) {:url url})))))

(defn branch->latest-artifact [branch]
  (let [artifact-urls (-> (str "https://api.github.com/repos/metabase/metabase/actions/runs?branch=" branch)
                          gh-get
                          :workflow_runs
                          ((fn [x] (mapv :artifacts_url x))))]
    (or (seek
          (fn [url]
            (let [artifact (gh-get url)
                  name->dl-url (->> artifact :artifacts (group-by :name) (into {}))]
              (first (get name->dl-url "metabase-ee-uberjar"))))
          artifact-urls)
        (do
          (println "\nCould not find an uberjar for branch" (c/red branch))
          (println "Our Github Actions retention period is currently 3 months.")
          (println "If you are looking to run an older branch, that can be why it is not found.")
          (println "Pushing an empty commit to the branch will rebuild it on Github Actions, which should take a few minutes.")
          (println "More info: https://docs.github.com/en/actions/managing-workflow-runs/removing-workflow-artifacts#setting-the-retention-period-for-an-artifact")
          (System/exit 1)))))

(defn download-mb-jar!
  [dl-path dl-url]
  (println (c/green (str "downloading into " dl-path "/metabase.zip from: " dl-url)))
  (shell {:dir dl-path} (str "curl"
                             " -H \"Accept:application/vnd.github+json\""
                             " -H \"Authorization:Bearer " (t/env "GH_TOKEN") "\""
                             " -Lo metabase.zip"
                             " " dl-url)))

(def download-dir
  ;; artifact zips will be downloaded into download-dir/<BRANCH-NAME>/
  (or (t/env "LOCAL_MB_DL" (fn [])) "../"))

(defn- check-gh-token []
  (t/env "GH_TOKEN"
         (fn [token]
           (println  "Please set " (c/green token) ".")
           (println (c/white "This API is available for authenticated users, OAuth Apps, and GitHub Apps."))
           (println (c/white "Access tokens require") (c/cyan "repo scope") (c/white "for private repositories and") (c/cyan "public_repo scope")  (c/white "for public repositories."))
           (println "More info at: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token")
           (System/exit 1))))

(defn download-and-run-latest-jar! [{:keys [branch port socket-repl]}]
  (check-gh-token)
  (let [*wait (t/wait (str "Finding uberjar for branch: " (c/green branch)))
        {artifact-id :id
         created-at :created_at
         dl-url :archive_download_url
         :as info} (branch->latest-artifact branch)
        branch-dir (str download-dir branch)]
    (reset! *wait false)
    (println (c/cyan "Found latest artifact!"))
    (println (c/magenta (str "           id: " artifact-id)))
    (println (c/magenta (str "   created-at: " created-at)))
    (println (c/magenta (str " download-url: " dl-url)))
    (shell (str "mkdir -p " branch-dir))
    (if (= (try (edn/read-string (slurp (str branch-dir "/info.edn")))
                (catch Throwable _ ::nothing-there))
           info)
      (println (c/yellow "Already downloaded artifact created at " created-at))
      (do
        (println (c/cyan "New version found, downloading..."))
        (download-mb-jar! branch-dir dl-url)))
    (println "Artifact download complete.")
    (spit (str branch-dir "/info.edn") info)
    (println "Unzipping artifact...")
    (try
      (shell {:dir branch-dir :out nil} "unzip -o metabase.zip")
      (catch Exception e (throw (ex-info
                                  "Problem unzipping... has the artifact expired?"
                                  (merge {:zip-location (str branch-dir "/metabase.zip")
                                          :zip-length (count (slurp (str branch-dir "/metabase.zip")))
                                          :branch branch}
                                         (if (< 10000 (count (slurp (str branch-dir "/metabase.zip"))))
                                           {:zip-contents (slurp (str branch-dir "/metabase.zip"))}))))))
    (println "Artifact unzipped!")
    (shell {:dir branch-dir :out nil} (str "mv target/uberjar/metabase.jar ./metabase_" branch ".jar"))
    (println (<< "starting branch {{branch}} of metabase on port:{{port}}..."))
    (future (do (while (not= 200 (:status (curl/get (str "localhost:" port) {:throw false})))
                  (Thread/sleep 1000))
                (shell (str "open http://localhost:" port))))
    (let [cmd (str "java "
                   (when socket-repl (str "-Dclojure.server.repl=\"{:port " socket-repl " :accept clojure.core.server/repl}\" "))
                   "-jar " "metabase_" branch ".jar")]
      (println (c/white "Running: ") (c/green cmd))
      (shell {:dir branch-dir
              :out :inherit
              :env {"MB_JETTY_PORT" port}} cmd))))
