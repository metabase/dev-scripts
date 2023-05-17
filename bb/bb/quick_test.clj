(ns bb.quick-test
  (:require
   [babashka.fs :as fs]
   [babashka.tasks :refer [shell]]
   [bask.colors :as c]
   [bb.tasks :as t]
   [clojure.string :as str]))

(def test-path (str (t/env "MB_DIR") "/test"))

(defn file->ns [path]
  (-> path
      str
      (str/replace (str (t/env "MB_DIR") "/test/") "")
      (str/replace #"\.clj$" "")
      (str/replace "_" "-")
      (str/replace "/" ".")))

(defn- test-nss [] (mapv file->ns (fs/glob test-path "**.clj")))

(defn run! [nss]
  (let [cmd (str "clj -X:dev:ee:ee-dev:test :only " (str/join " " nss))]
    (t/print-env "mb")
    (println (c/red "==========="))
    (println (c/red "| Running |"))
    (println (c/red "==========="))
    (println (c/bold cmd) "\n")
    (shell {:dir (t/env "MB_DIR")
            :env (t/env)} cmd)))
