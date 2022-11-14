(ns bb.tasks
  (:require [bask.colors :as c]
            [babashka.tasks :refer [shell]]
            [bencode.core :as bencode]
            [clojure.edn :as edn]
            [clojure.string :as str]
            [selmer.parser :refer [<<]]))

(defn install-or-noop [program install-fn]
  (letfn [(can-run? [program] (= 0 (:exit (shell {:out nil} (str "command -v " program)))))]
    (when-not (can-run? program)
      (println (<< "You don't have {{program}} installed. Installing now..."))
      (install-fn)
      (println (<< "{{program}} should be installed now. Thanks!")))))

(defn wait
  "Print message, followed by .'s until @*continue? is false."
  [message]
  (let [*continue? (atom true)]
    (future
      (print (str message ": ")) (flush)
      (while @*continue?
        (print "|") (flush)
        (Thread/sleep 1000)))
    (fn cancel-wait []
      (reset! *continue? false)
      (println))))

(defn- git-fetch [mb-dir]
  (let [done (wait "Fetching metabase branches")]
    (shell {:dir mb-dir :out :string :err :string} "git fetch")
    (done)))

(defn list-branches [mb-dir]
  (git-fetch mb-dir)
  (letfn [(remove-origin [b] (str/replace (str/trim b) (re-pattern "^origin/") ""))]
    (mapv remove-origin
          (str/split-lines
            (->> "git branch -r" (shell {:dir mb-dir :out :string}) :out)))))

(defn whoami [] (str/trim (:out (shell {:out :string} "whoami"))))

(defn env
  ([] (into {} (System/getenv)))
  ([env-var] (env env-var (fn [] (println "Warning: cannot find " (c/red env-var) " in env."))))
  ([env-var error-thunk] (or ((env) (name env-var)) (error-thunk))))

(defn print-env
  ([] (print-env ".*" (env)))
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

(defn- os
  "Returns :win, :mac, :unix, or nil"
  []
  (case (str/lower-case (apply str (take 3 (System/getProperty "os.name"))))
    "win" :win
    "mac" :mac
    "nix" :unix
    "nux" :unix
    nil))

(defn open-url
  "Opens the given file (a string, File, or file URI) in the default
  application for the current desktop environment. Returns nil"
  [url]
  {:pre [(str/starts-with? url "http")]}
  ;; There's an 'open' method in java.awt.Desktop but it hangs on Windows
  ;; using Clojure Box and turns the process into a GUI process on Max OS X.
  ;; Maybe it's ok for Linux?
  (case (os)
    :mac (shell "open " url)
    :win (shell "cmd " (str "/c start " url))
    :unix (shell "xdg-open " url))
  nil)

 ;; taken from https://book.babashka.org/#_interacting_with_an_nrepl_server
(defn nrepl-eval [port expr]
  (let [s (java.net.Socket. "localhost" port)
        out (.getOutputStream s)
        in (java.io.PushbackInputStream. (.getInputStream s))
        _ (bencode/write-bencode out {"op" "eval" "code" expr})
        bytes (get (bencode/read-bencode in) "value")]
    (String. bytes)))
