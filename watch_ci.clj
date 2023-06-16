#!/usr/bin/env bb

(ns watch-ci
  (:require [babashka.curl :as curl]
            [babashka.tasks :refer [shell]]
            [bask.colors :as c]
            [bb.cli :as cli]
            [cheshire.core :as json]
            [clojure.edn :as edn]
            [clojure.pprint :as pp]
            [clojure.string :as str]
            [selmer.parser :refer [<<]]))

(defn env
  ([] (into {} (System/getenv)))
  ([env-var] (env env-var (fn [] (println "Warning: cannot find " (c/red env-var) " in env."))))
  ([env-var error-thunk] (or ((env) (name env-var)) (error-thunk))))

(defn- gh-GET [url]
  (try (-> url
           (curl/get {:headers {"Accept" "application/vnd.github+json" "Authorization" (str "Bearer " (env "GH_TOKEN"))}})
           :body
           (json/decode true))
       (catch Exception e
         (let [{:keys [status]} (ex-data e)]
           (when (= status 401) (println (c/red "Is your GH_TOKEN out of date?")))
           (throw (ex-info (str "Error trying to get url " url " status: " status)
                           {:status status :url url}))))))

(def mb-dir (env "MB_DIR" (fn []
                            (println (c/red "Please set MB_DIR env variable to your metabase directory!"))
                            (System/exit 1))))

(defn current-branch []
  (->> "git rev-parse --abbrev-ref HEAD"
       (shell {:dir mb-dir :out :string})
       :out
       str/trim))

(def branch (current-branch))

(defn checks-for-branch
  ;; note: this is a ref, so it can e.g. also be a sha.
  []
  (->> (str "https://api.github.com/repos/metabase/metabase/commits/" branch "/check-runs")
       gh-GET
       :check_runs
       (mapv (comp (fn [x] (if (nil? x) :in-progress (keyword x))) :conclusion))
       frequencies
       (sort-by first)
       reverse))

(def pretty {:success "✅" :skipped "⏭️ " :cancelled "⏹️" :in-progress "🔄" :failure "❌"})

(defn print-report-line [checks]
  (print (str "[" (.format (java.text.SimpleDateFormat. "hh:mm:ss a") (java.util.Date.)) "] "))
  (doseq [[status count] checks]
    (print (str/join (repeat count (pretty status)))) (print " "))
  (println)
  (flush))

(defn -main []
  ;; (prn (env))
  (println "Legend:" (pr-str pretty))
  (loop [n 0]
    (let [checks (checks-for-branch)]
      (when (zero? (mod n 20))
        (println (c/green "Checking CI for branch:") (c/white branch) (c/green ".")))
      (print-report-line checks)
      (when-not (= (keys checks) [:success])
        (Thread/sleep 5000)
        (recur (inc n))))))

(when (= *file* (System/getProperty "babashka.file")) (-main))
