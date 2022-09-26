(ns bb.colors
  (:require [clojure.string :as str]))

(defn-  x [s] (str "\u001B[" s "m"))
(def ^:private codes {:reset (x 0)
                      :black (x 30) :black-bg (x 40)
                      :red (x 31) :red-bg (x 41)
                      :green (x 32) :green-bg (x 42)
                      :yellow (x 33) :yellow-bg (x 43)
                      :blue (x 34) :blue-bg (x 44)
                      :purple (x 35) :purple-bg (x 45)
                      :cyan (x 36) :cyan-bg (x 46)
                      :white (x 37) :white-bg (x 47)})

(defn- ->color
  ([fg-color string]
   (->color fg-color :black-bg string))
  ([fg-color bg-color string]
   (let [fg (get codes fg-color (:white codes))
         bg (get codes bg-color (:black-bg codes))]
     (str bg fg (x 1) string (:reset codes)))))

(defn println
  ([f string] (println f :black-bg string))
  ([f b string]
   (clojure.core/println (->color f b string))))

(defn print
  ([f string] (print f :black-bg string))
  ([f b string]
   (clojure.core/print (->color f b string))
   (flush)))

(defn black [& s]  (println :black :white (str/join " " s)))
(defn red [& s]    (println :red :black (str/join " " s)))
(defn green [& s]  (println :green :black (str/join " " s)))
(defn yellow [& s] (println :yellow :black (str/join " " s)))
(defn blue [& s]   (println :blue :black (str/join " " s)))
(defn purple [& s] (println :purple :black (str/join " " s)))
(defn cyan [& s]   (println :cyan :black (str/join " " s)))
(defn white [& s]  (println :white :black (str/join " " s)))

(defn sample []
  (doseq [bg (->> codes keys (filter (fn [k] (str/ends-with? (name k) "-bg"))) (remove #{:reset}) sort)
          fg (->> codes keys (remove (fn [k] (str/ends-with? (name k) "-bg"))) (remove #{:reset}) sort)
          :when (not (str/starts-with? (name bg) (name fg)))]
    (println fg bg (str "This is [" fg ", " bg "]."))))

;; bb colors.clj
(when (= *file* (System/getProperty "babashka.file"))
  (sample))
