(ns bb.dl-and-run
  (:require
   [babashka.curl :as curl]
   [babashka.tasks :refer [shell]]
   [bask.colors :as c]
   [bb.tasks :as t]
   [cheshire.core :as json]
   [clojure.edn :as edn]
   [selmer.parser :refer [<<]]))

(defn- keep-first
  "like (fn [f coll] (first (keep f coll))) but does not do chunking."
  [f coll]
  (reduce (fn [_ element] (when-let [resp (f element)] (reduced resp))) nil coll))

(defn gh-get [url]
  (try (-> url
           (curl/get {:headers {"Accept" "application/vnd.github+json"
                                "Authorization" (str "Bearer " (t/env "GH_TOKEN"))}})
           :body
           (json/decode true))
       (catch Exception e
         (let [{:keys [status]} (ex-data e)]
           (when (= status 401) (println (c/red "Is your GH_TOKEN out of date?")))
           (throw (ex-info (str "Error trying to get url " url " status: " status)
                           {:status status :url url}))))))

(defn is-artifact-url-uberjar? [ee-or-oss]
  {:pre [#{"ee" "oss"} ee-or-oss]}
  (fn [url]
    (let [artifact (gh-get url)
          name->dl-url (->> artifact :artifacts (group-by :name) (into {}))]
      ;; "metabase-oss-uberjar"
      (first (get name->dl-url (str "metabase-" ee-or-oss "-uberjar"))))))

(defn- no-artifact-found-error! [branch]
  (println "\nCould not find an uberjar for branch" (c/red branch))
  (println "Our Github Actions retention period is currently 3 months.")
  (println "If you are looking to run an older branch, that can be why it is not found.")
  (println "Pushing an empty commit to the branch will rebuild it on Github Actions, which should take a few minutes.")
  (println "More info: https://docs.github.com/en/actions/managing-workflow-runs/removing-workflow-artifacts#setting-the-retention-period-for-an-artifact")
  (println "Could also happen if there are a lot of commits in quick succession")
  (System/exit 1))

(defn branch->latest-artifact [branch]
  (let [artifact-urls (->> branch
                           ;; TODO is 100 this enough?
                           (str "https://api.github.com/repos/metabase/metabase/actions/runs?per_page=100&branch=")
                           gh-get
                           :workflow_runs
                           (mapv :artifacts_url))]

    (or (keep-first (is-artifact-url-uberjar? "ee") artifact-urls)
        (no-artifact-found-error! branch))))

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

(defn check-gh-token! []
  (t/env "GH_TOKEN"
         (fn []
           (println  "Please set GH_TOKEN.")
           (println (c/white "This API is available for authenticated users, OAuth Apps, and GitHub Apps."))
           (println (c/white "Access tokens require") (c/cyan "repo scope") (c/white "for private repositories and") (c/cyan "public_repo scope")  (c/white "for public repositories."))
           (println "More info at: https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token")
           (println "You can make one (classic) here: https://github.com/settings/tokens")
           (println (c/bold "Be sure to tick the *repo* permission."))
           (System/exit 1))))

(defn download-latest-jar! [{:keys [branch]}]
  (let [finished (t/wait (str "Finding uberjar for branch" (c/green branch)) "📞")
        {artifact-id :id
         created-at :created_at
         dl-url :archive_download_url
         sha :head_sha
         :as info_} (branch->latest-artifact branch)
        branch-dir (str download-dir branch)
        info (into (sorted-map) (assoc info_ :branch branch :branch-dir branch-dir))]
    (finished)
    (println (c/cyan "Found latest artifact!"))
    (println (c/magenta (str "      git SHA: " (c/green sha))))
    (println (c/magenta (str "  Artifact Id: " (c/green artifact-id))))
    (println (c/magenta (str "   Created At: " (c/green created-at))))
    ;; TODO
    ;; We can check that the sha matches
    ;; I couldn't find the latest.
    ;; - you need to manually build it, or try again later. sorry.
    ;; - _or_ use the older artifact?
    (println (c/magenta (str " Download Url: " (c/green dl-url))))
    (prn info)
    (println "Download directory: " branch-dir)
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
    info))

(defn run-jar! [info port socket-repl]
  (let [{:keys [branch branch-dir]} info]
    (println "Unzipping artifact...")
    (try
      (shell {:dir branch-dir :out nil} "unzip -o metabase.zip")
      (catch Exception _ (throw (ex-info
                                  "Problem unzipping... has the artifact expired?"
                                  (merge {:zip-location (str branch-dir "/metabase.zip")
                                          :zip-length (count (slurp (str branch-dir "/metabase.zip")))
                                          :branch branch}
                                         (when (< 10000 (count (slurp (str branch-dir "/metabase.zip"))))
                                           {:zip-contents (slurp (str branch-dir "/metabase.zip"))}))))))
    (println "Artifact unzipped!")
    (shell {:dir branch-dir :out nil} (str "mv target/uberjar/metabase.jar ./metabase_" branch ".jar"))
    (println (<< "starting branch {{branch}} of metabase on port:{{port}}..."))
    (future (do (while (not= 200 (:status (curl/get (str "localhost:" port) {:throw false})))
                  (Thread/sleep 1000))
                (t/open-url (str "http://localhost:" port))))
    (let [cmd (str "java "
                   (when socket-repl (str "-Dclojure.server.repl=\"{:port " socket-repl " :accept clojure.core.server/repl}\" "))
                   "-jar " "metabase_" branch ".jar")
          env+ (assoc (t/env) "MB_JETTY_PORT" port)]
      (println (c/white "Running: ") (c/green cmd))
      (t/print-env "mb" env+)
      (shell {:dir branch-dir :out :inherit :env env+} cmd))))

(defn download-and-run-latest-jar! [{:keys [branch port socket-repl] :as args}]
  (let [info (download-latest-jar! args)]
    (run-jar! info port socket-repl)))