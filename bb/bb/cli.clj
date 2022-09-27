(ns bb.cli
  (:require [babashka.deps :as deps]
            [clojure.tools.cli :refer [parse-opts]]
            [bb.colors :as c]
            [bb.tasks :as tasks]))

(deps/add-deps '{:deps {table/table {:mvn/version "0.5.0"}}})
(require '[table.core :as t])
(defn tbl [x] (t/table x :fields [:short :long :title :required? :default :options :id] :style :unicode-3d))

(defn- ->cli-tools-option [{:keys [title short long id default parse-fn update-fn validate] :as hybrid-opt}]
  (vec (concat [short long title]
               (when id [:id id])
               (when default [:default default])
               (when parse-fn [:parse-fn parse-fn])
               (when update-fn [:update-fn update-fn])
               (when validate [:validate validate]))))

(defn- check-print-help [args current-task options]
  (when (or (get (set args) "-h")
            (get (set args) "--help"))
    (c/green (str "  " (:doc current-task)))
    (if (seq options)
      (do (println "")
          (doseq [opt options] (println "") (c/cyan (str " " (:short opt) " " (:long opt))) (tbl (dissoc opt :short :long)))
          (when-let [examples (:examples current-task)]
            (c/white "\n#### Examples:")
            (doseq [[cmd effect] examples]
              (c/white cmd) (println (str "  - " effect)))))
      (c/cyan " accepts no command line arguments."))
    (System/exit 0)))

(defn ->ask [{:keys [prompt id options title] :as option}]
  {:name id
   :type (or prompt :input)
   :limit 10
   :message title
   :choices (if (fn? options) (options) options)})

(defn ask-unknown! [cli-options all-options]
  (let [answered-ids (set (keys cli-options))
        unanswered (remove #(or
                              (:cli-only? %)
                              (answered-ids (:id %))) all-options)
        to-ask (mapv ->ask unanswered)]
    (if (empty? to-ask)
      cli-options
      (merge cli-options (tasks/ask! to-ask)))))

(defn- menu-cli
  "Gets required cli options through a menu when not provided by users."
  [current-task opts args]
  (check-print-help args current-task opts)
  (let [options (mapv ->cli-tools-option opts)
        {:keys [error summary arguments] parsed-opts :options} (try (parse-opts args options)
                                                                    (catch Throwable t {:error "parse-opts threw."}))
        _ (when error (println "WARNING:" "args, " args  "options," options " | " error "|" summary))
        required-hopts (filter :required? options)
        missing-opts (remove (fn [rho] (contains? parsed-opts (:id rho))) required-hopts)
        missing-and-unaskable (remove (fn [rho] (-> rho :options seq)) missing-opts)
        _ (when (seq missing-and-unaskable)
            (c/red "Missing required option(s) without a menu-selectable value!")
            (tbl options)
            (System/exit 1))
        missing-and-askable (filter (fn [rho] (-> rho :options seq)) missing-opts)
        asked-opts (into {} (for [hybrid-option missing-and-askable]
                              (println "todo: ask (menu-ask hybrid-option)" (pr-str hybrid-option))))
        cli (assoc (merge parsed-opts asked-opts) :args arguments)]
    (ask-unknown! cli opts)))

(defn menu!
  "options have keys that map to clojure.tools.cli options via [[->cli-tools-option]].

  Custom keys are:

  :prompt <:autocomplete|:input|:numeral|:confirm|:multiselect|:password|:toggle>
  defaults to input in [[->ask]], the type of prompt to use to ask the user to
  fill out the option.

  :cli-only? <true|false>
  this option will not be asked about in the interavtive menu.


  n.b.

  one handy trick is to add a bb task like

  x (prn (menu! (current-task)
         {:id :my-arg
          :short \"-p\"
          :long \"--port PORT\"
          :required? true
          :prompt :multiselect
          :options [\"apple\" \"banana\" \"egg salad\" \"green onions\" \"mango\"]}))

  and call it via running `bb x` in your terminal
  "
  [current-task & options]
  (menu-cli current-task options *command-line-args*))
