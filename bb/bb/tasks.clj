(ns bb.tasks
  (:require [babashka.fs :as fs]
            [clojure.term.colors :as c]
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
  ([var] (env var (fn [_])))
  ([var error-fn] (or ((env) (name var)) (error-fn var))))

(defn whoami [] (str/trim (:out (shell {:out :string} "whoami"))))

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
