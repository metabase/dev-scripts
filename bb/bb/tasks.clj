(ns bb.tasks
  (:require [clojure.term.colors :as c]
            [babashka.tasks :refer [shell]]
            [clojure.string :as str]
            [selmer.parser :refer [<<]]))

(defn install-or-noop [program install-fn]
  (letfn [(can-run? [program] (= 0 (:exit (shell {:out nil} (str "command -v " program)))))]
    (when-not (can-run? program)
      (println (<< "You don't have {{program}} installed. Installing now..."))
      (install-fn)
      (println (<< "{{program}} should be installed now. Thanks!")))))

(defn- wait
  "Print message, followed by .'s until @*continue? is false."
  [message]
  (let [*continue? (atom true)]
    (future
      (print (str message ": ")) (flush)
      (while @*continue?
        (print "|") (flush)
        (Thread/sleep 1000)))
    *continue?))

(defn- git-fetch [mb-dir]
  (let [*wait (wait "Fetching metabase branches")]
    (shell {:dir mb-dir :out :string :err :string} "git fetch")
    (reset! *wait false)))

(defn list-branches [mb-dir]
  (git-fetch mb-dir)
  (letfn [(remove-origin [b] (str/replace (str/trim b) (re-pattern "^origin/") ""))]
    (mapv remove-origin
          (str/split-lines
            (->> "git branch -r" (shell {:dir mb-dir :out :string}) :out)))))

(defn whoami [] (str/trim (:out (shell {:out :string} "whoami"))))

(defn env
  ([] (into {} (System/getenv)))
  ([var] (env var (fn [_var] (println "Warning: cannot find " (c/red var) " in env."))))
  ([var error-fn] (or ((env) (name var)) (error-fn var))))

(defn print-env
  ([] (print-env "" (env)))
  ([match] (print-env match (env)))
  ([match env]
   (let [important-env (->> env
                            (filter (fn [[k _]] (re-find (re-pattern (str "(?i).*" match ".*")) k)))
                            (sort-by first))
         key-print-width (inc (apply max (mapv (comp count first) important-env)))
         spaces (fn [setting] (str (apply str (repeat (- key-print-width (count setting)) " ")) setting))]
     (println)
     (doseq [[setting value] important-env]
       (print (c/yellow (spaces setting))) (print (c/white " : ")) (println (c/cyan value))))))
