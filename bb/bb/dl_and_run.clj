(ns bb.dl-and-run
  (:require [babashka.tasks :refer [shell]]
            [babashka.curl :as curl]
            [bb.colors :as c]
            [bb.tasks :as t]
            [selmer.parser :refer [<<]]
            [cheshire.core :as json]
            [clojure.edn :as edn]))

(defn list-action-artifacts
  ([] (list-action-artifacts 1))
  ([page-num]
   (-> (str "https://api.github.com/repos/metabase/metabase/actions/artifacts?per_page=100&page=" page-num)
       (curl/get {:headers {"Accept" "application/vnd.github+json"
                            "Authorization" (str "Bearer " (t/env "GH_PERSONAL_ACCESS"))}})
       :body
       (json/decode true)
       :artifacts)))

(def parallel-page-requests "How many requests to make for build artifacts per chunk"
  30)

(def last-page "The last page of build artifacts downloaded"
  (atom 1))

(def *branch->action-artifacts "branch -> all known action-artifacts"
  (atom {}))

(defn- get-latest-artifact [action-artifacts]
  (first (sort-by :updated_at action-artifacts)))

(defn- get-artifacts []
  (when-not (t/env "GH_PERSONAL_ACCESS")
    (c/red "Please put your github access token into GH_PERSONAL_ACCESS env var.")
    (System/exit 1))
  (let [last-page (swap! last-page + parallel-page-requests)
        page-range [(- last-page parallel-page-requests) last-page]
        ;; _ (println "getting artifacts for page-range: " page-range)
        futures (map #(future (list-action-artifacts %)) (apply range page-range))
        values (apply concat (map deref futures))
        branch->action-artifacts (->> values
                                      (group-by #(-> % :workflow_run :head_branch)))]
    (swap! *branch->action-artifacts (fn [old] (merge-with (comp vec concat) old branch->action-artifacts)))))

(defn download-mb-jar!
  [path dl-path artifact-id]
  (println "downloading from:"
           (<< "https://api.github.com/repos/metabase/metabase/actions/artifacts/{{artifact-id}}/zip"))
  (shell {:dir dl-path} (str "curl"
                             " -H \"Accept:application/vnd.github+json\""
                             " -H \"Authorization:Bearer " (t/env "GH_PERSONAL_ACCESS") "\""
                             " -Lo metabase.zip"
                             " https://api.github.com/repos/metabase/metabase/actions/artifacts/" artifact-id "/zip")))

(def download-dir
  ;; artifact zips will be downloaded into download-dir/<BRANCH-NAME>/
  (or (t/env "LOCAL_MB_DL") "../"))

(defn download-and-run-latest-jar! [{:keys [branch port socket-repl]}]
  (let [{artifact-id :id
         created-at :created_at
         :as info} (do (while (false? (get (get-artifacts) branch false))
                         (get-artifacts)) ;; get-artifacts puts the new ones into *branch->action-artifacts.
                       (get-latest-artifact (get @*branch->action-artifacts branch)))
        branch-dir (str download-dir branch)]
    (println (<< "Found latest artifact, created-at: {{created-at}} id: {{artifact-id}}"))
    (shell (str "mkdir -p " branch-dir))
    (if (= (try (edn/read-string (slurp (str branch-dir "/info.edn")))
                (catch Throwable _ ::nothing-there))
           info)
      (c/blue "Already downloaded branch.")
      (do
        (c/blue "New version of branch found, downloading...")
        (download-mb-jar! (str branch-dir "/metabase.zip") branch-dir artifact-id)))
    (println "Artifact download complete.")
    (spit (str branch-dir "/info.edn") info)
    (println "Unzipping artifact...")
    (shell {:dir branch-dir :out nil} "unzip -o metabase.zip")
    (println "Artifact unzipped!")
    (shell {:dir branch-dir :out nil} (str "mv target/uberjar/metabase.jar ./metabase_" branch ".jar"))
    (println (<< "starting branch {{branch}} of metabase on port:{{port}}..."))
    (future (do (while (not= 200 (:status (curl/get (str "localhost:" port)) {:throw false}))
                  (Thread/sleep 1000))
                (shell (str "open http://localhost:" port))))
    (let [cmd (str "java "
                   (when socket-repl (str "-Dclojure.server.repl=\"{:port " socket-repl " :accept clojure.core.server/repl}\" "))
                   "-jar " "metabase_" branch ".jar")]
      (c/print :white "Running: ") (c/println :green cmd)
      (shell {:dir branch-dir
              :out :inherit
              :env {"MB_JETTY_PORT" port}} cmd))))
