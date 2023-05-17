(ns bb.quick-test
  (:require [babashka.tasks :refer [shell]]
            [babashka.curl :as curl]
            [bask.colors :as c]
            [bask.bask :as b]
            [bb.tasks :as t]
            [babashka.fs :as fs]
            [selmer.parser :refer [<<]]
            [cheshire.core :as json]
            [clojure.edn :as edn]
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
