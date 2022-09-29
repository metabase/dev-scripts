(ns bb.cli
  (:require [babashka.deps :as deps]
            [clojure.tools.cli :refer [parse-opts]]
            [clojure.term.colors :as c]
            [bask.bask :as b]))

(deps/add-deps '{:deps {table/table {:mvn/version "0.5.0"}}})
(require '[table.core :as t])
(defn tbl [x] (t/table x :fields [:short :long :msg :required? :default :options :id] :style :unicode-3d))

(defn- ->cli-tools-option [{:keys [msg short long id default parse-fn update-fn validate] :as opt}]
  (vec (concat [short long msg]
               (when id [:id id])
               (when default [:default default])
               (when parse-fn [:parse-fn parse-fn])
               (when update-fn [:update-fn update-fn])
               (when validate [:validate validate]))))

(defn- check-print-help [args current-task options]
  (when (or (get (set args) "-h")
            (get (set args) "--help"))
    (println (c/green (str "  " (:doc current-task))))
    (if (seq options)
      (do (doseq [opt options] (println) (println (c/cyan (str " " (:short opt) " " (:long opt) " " (:msg opt)))) (tbl (dissoc opt :short :long :msg)))
          (when-let [examples (:examples current-task)]
            (println (c/white "\n#### Examples:"))
            (doseq [[cmd effect] examples]
              (println (c/white cmd) " -" effect))))
      (println (c/cyan " accepts no command line arguments.")))
    (System/exit 0)))

(defn ->ask [{:keys [id msg prompt choices] :as _option}]
  {:id id
   :msg msg
   :type prompt
   :choices (if (delay? choices) @choices choices)})

(defn ask-unknown! [cli-options all-options]
  (let [answered-ids (set (keys cli-options))
        unanswered (remove #(or (nil? (:prompt %)) (answered-ids (:id %))) all-options)
        to-ask (mapv ->ask unanswered)]
    (if (empty? to-ask)
      cli-options
      (merge cli-options (apply b/ask! to-ask)))))

(defn- menu-cli
  "Gets required cli options through a menu when not provided by users."
  [current-task opts args]
  (check-print-help args current-task opts)
  (let [options (mapv ->cli-tools-option opts)
        {:keys [error summary arguments] parsed-opts :options} (try (parse-opts args options)
                                                                    (catch Throwable t {:error "parse-opts threw."}))
        _ (when error (println "WARNING:" "args, " args  "options," options " | " error "|" summary))
        required-opts (filter :required? options)
        missing-opts (remove (fn [req-opt] (contains? parsed-opts (:id req-opt))) required-opts)
        missing-and-unaskable (remove (fn [rho] (-> rho :options seq)) missing-opts)
        missing-and-askable (filter (fn [rho] (-> rho :options seq)) missing-opts)
        _ (when (seq missing-and-unaskable)
            (println (c/red "Missing required option(s) without a menu-selectable value!"))
            (tbl options)
            (System/exit 1))
        asked-opts (into {} (for [hybrid-option missing-and-askable]
                              (println "todo: ask (menu-ask hybrid-option)" (pr-str hybrid-option))))
        cli (assoc (merge parsed-opts asked-opts) :args arguments)]
    (ask-unknown! cli opts)))

(defn menu!
  "options have keys that map to clojure.tools.cli options via [[->cli-tools-option]].

  Custom keys are:

  :prompt one of :text :number :select :multi
  When missing a :prompt key, we will not ask this quesion on the cli menu.
  So if it is required, it must be passed via cli flags.

  n.b.

  one handy trick is to add a bb task like

  x (prn (menu! (current-task)
         {:id :fav-foods
          :short \"-p\"
          :long \"--port PORT\"
          :required? true
          :prompt :multi
          :choices [\"apple\" \"banana\" \"egg salad\" \"green onions\" \"mango\"]}))

  and call it via running `bb x` in your terminal
  "
  [current-task & options]
  (menu-cli current-task options *command-line-args*))
