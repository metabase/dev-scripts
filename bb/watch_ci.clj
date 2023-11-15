(ns bb.watch-ci
  (:require [clojure.string :as str]
            [bb.dl-and-run :as dl]
            [table.core :as table]))

(defn checks-for-branch [branch]
  (->> (str "https://api.github.com/repos/metabase/metabase/commits/" branch "/check-runs")
       dl/gh-get
       :check_runs
       (mapv #(select-keys % [:conclusion :name :html_url]))
       (mapv #(update % :conclusion (fnil keyword "in-progress")))
       (sort-by :conclusion)))

(defn tc [color & s]
  (let [cm {:bold 1
            :gray 30 :grey 30 :red 31 :green 32 :yellow 33
            :blue 34 :magenta 35 :cyan 36 :white 37
            :on-gray 40 :on-grey 40 :on-red 41 :on-green 42 :on-yellow 43
            :on-blue 44 :on-magenta 45 :on-cyan 46 :on-white 47}]
    (if-let [c (get cm color)]
      (str "[" c "m" (str/join s) "\033[0m")
      (str/join s))))

(defn colorize-line [line]
  (or (first (for [[re color] [[#"success" :green] [#"in-progress" :cyan] [#"failure" :red] [#"skipped" :yellow]]
                   :when (re-find re line)]
               (tc color line)))
      line))

(defn branch [branch]
  (loop []
    (let [checks (checks-for-branch branch)]
      (println (tc :red (tc :bold branch)) (str "[ " (.format (java.text.SimpleDateFormat. "hh:mm:ss a") (java.util.Date.)) " ]"))
      (->> (table/table-str checks)
           str/split-lines
           (map colorize-line)
           (str/join "\n")
           println)
      (if (= #{:success} (set (map :conclusion checks)))
        (do
          (println (tc :green branch "passed."))
          (System/exit 0))
        (do (Thread/sleep 10000)
            (recur))))))
