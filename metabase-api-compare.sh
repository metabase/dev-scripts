#!/usr/bin/env bash
#_" -*- mode: clojure; -*-"
#_(
   "exec" "clojure" "-Sdeps" "{:deps {clj-kondo/clj-kondo {:mvn/version \"2020.12.12\"} org.clojure/tools.deps.alpha {:mvn/version \"0.9.857\"} org.slf4j/slf4j-nop {:mvn/version \"1.7.30\"} lambdaisland/deep-diff2 {:mvn/version \"2.0.108\"} juji/editscript {:mvn/version \"0.5.4\"}}}" "-M" "$0" "$@"
   )

;; Adapted from borkdude's api_diff.clj script: https://gist.github.com/borkdude/2b963db1582654ec28bfd40b4dc35748
;; Example usage:
;;   download jars to temp files (from https://downloads.metabase.com), then compare
;; metabase-api-compare.sh "v0.40.5" "v0.41.0-RC1" > /tmp/diff.txt
;;
;;   directly reference uberjars already on local disk
;; metabase-api-compare.sh file:/Users/jeff/dev/metabase/uberjar-testing/0.40.5/metabase.jar file:/tmp/metabase-release/metabase/target/uberjar/metabase.jar >/tmp/diff.txt

(require '[clj-kondo.core :as clj-kondo])
(require '[clojure.edn :as edn])

(def v1 (first *command-line-args*))
(def v2 (second *command-line-args*))

(require '[clojure.java.io :as io])
(require '[clojure.tools.deps.alpha :as tda])

(import java.io.File)

(defn download! [uri file]
  (with-open [in  (io/input-stream uri)
              out (io/output-stream file)]
    (io/copy in out)))

(defn metabase-version->download-url [v]
  (format "https://downloads.metabase.com/%s/metabase.jar" v))

(defn path [v]
  (if (re-matches #"file:/.*" v)
      v
      (let [temp-file (File/createTempFile (str "metabase-" v) ".jar")]
        (.deleteOnExit temp-file)
        (-> (metabase-version->download-url v)
            (download! temp-file))
        (.getAbsolutePath temp-file))))

(def path1 (path v1))
(def path2 (path v2))

(defn index-by
  [f coll]
  (persistent! (reduce #(assoc! %1 (f %2) %2) (transient {}) coll)))

(defn group [vars]
  (->> vars
       (map #(select-keys % [:ns :name :fixed-arities :varargs-min-arity]))
       (index-by (juxt :ns :name))))

(defn vars [lib]
  (-> (clj-kondo/run! {:lint [lib] :config {:output {:analysis true :format :edn}}})
      :analysis :var-definitions #_ clean))

(def vars-1 (vars path1))
(def vars-2 (vars path2))

#_(require '[lambdaisland.deep-diff2 :as ddiff])
#_(ddiff/pretty-print (ddiff/diff vars-1 vars-2))

;; (require '[editscript.core :as c])
;; (require '[editscript.edit :as e])
;; (def d (c/diff vars-1 vars-2))

;; (require '[clojure.pprint :refer [pprint]])
;; (pprint (e/get-edits d))

(defn var-symbol [[k v]]
  (str k "/" v))

(def compare-group-1 (group vars-1))
(def compare-group-2 (group vars-2))

(def lookup-1 (index-by (juxt :ns :name) vars-1))

(doseq [[k var-1] compare-group-1]
  (if-let [var-2 (get compare-group-2 k)]
    (let [fixed-arities-v1 (:fixed-arities var-1)
          fixed-arities-v2 (:fixed-arities var-2)
          varargs-min-arity (:varargs-min-arity var-2)]
      (doseq [arity fixed-arities-v1]
        (when-not (or (contains? fixed-arities-v2 arity)
                      (and varargs-min-arity (>= arity varargs-min-arity)))
          (let [{:keys [:filename :row :col :private]} (get lookup-1 k)]
            (println (str filename ":" row ":" col ":") (str (if private "warning" "error") ":")
                     "Arity" arity "of" (var-symbol k) "was removed.")))))
    (let [{:keys [:filename :row :col :private]} (get lookup-1 k)]
      (println (str filename ":" row ":" col ":") (str (if private "warning" "error") ":")
               (var-symbol k) "was removed."))))
