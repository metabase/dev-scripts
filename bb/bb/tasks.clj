(ns bb.tasks
  (:require [babashka.fs :as fs]
            [babashka.tasks :refer [shell]]
            [clojure.string :as str]
            [selmer.parser :refer [<<]]
            [clojure.edn :as edn]))

(defn install-or-noop [program install-fn]
  (letfn [(can-run? [program] (= 0 (:exit (shell {:out nil} (str "command -v " program)))))]
    (when-not (can-run? program)
      (println (<< "You don't have {{program}} installed. Installing now..."))
      (install-fn)
      (println (<< "{{program}} should be installed now. Thanks!")))))

(defn ask! [qs]
  (install-or-noop "npm" (fn [] (c/red "Please install npm.") (System/exit 1)))
  (install-or-noop "fullfill" (fn [] (shell "npm install -g fullfill")))
  (let [seed (apply str (repeatedly 10 (fn [] (rand-nth "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"))))
        asker-result-file (str ".out_" seed ".edn")
        _ (future (shell (str "fullfill" " -o " asker-result-file " -e '" (pr-str qs) "'")))]
    (while (not (fs/exists? asker-result-file)) (Thread/sleep 50))
    (let [v (slurp asker-result-file)]
      (fs/delete asker-result-file)
      (edn/read-string v))))

(defn list-branches [mb-dir]
  (letfn [(remove-origin [b] (str/replace (str/trim b) (re-pattern "^origin/") ""))]
    (print "Fetching metabase branches...") (flush)
    (with-out-str (shell {:dir mb-dir :out :string} "git fetch"))
    (print "\r") (flush)
    (mapv remove-origin
          (str/split-lines
            (->> "git branch -r" (shell {:dir mb-dir :out :string}) :out)))))

(defn env
  ([] (into {} (System/getenv)))
  ([var] (get (env) (name var))))

