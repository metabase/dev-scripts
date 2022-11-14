(ns bb.cli
  (:require [bask.bask :as b]
            [bask.colors :as c]
            [clojure.tools.cli :refer [parse-opts]]
            [table.core :as t]
            [clojure.string :as str]))

(defn tbl [x]
  (t/table x :fields [:short :long :msg :default :options :id :prompt] :style :unicode-3d))

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
            (println "\n\nExamples:")
            (doseq [[cmd effect] examples]
              (println "\n" cmd "\n -" (c/magenta effect)))))
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
      (merge cli-options (b/ask! to-ask)))))

(defn- menu-cli
  "Gets required cli options through a menu when not provided by users."
  [current-task opts args]
  (check-print-help args current-task opts)
  (let [options (mapv ->cli-tools-option opts)
        {:keys [error summary arguments] parsed-opts :options} (try (parse-opts args options)
                                                                    (catch Throwable _t {:error "parse-opts threw."}))
        _ (when error (println "WARNING:" "args, " args  "options," options " | " error "|" summary))
        required-opts (filter :prompt options)
        missing-opts (remove (fn [req-opt] (contains? parsed-opts (:id req-opt))) required-opts)
        missing-and-unaskable (remove #(-> % :options seq) missing-opts)
        missing-and-askable (filter #(-> % :options seq) missing-opts)
        _ (when (seq missing-and-unaskable)
            (println (c/red "Missing required option(s) without a menu-selectable value!"))
            (tbl options)
            (System/exit 1))
        asked-opts (into {} (for [hybrid-option missing-and-askable]
                              (println "todo: ask (menu-ask hybrid-option)" (pr-str hybrid-option))))
        cli (assoc (merge parsed-opts asked-opts) :args arguments)]
    (ask-unknown! cli opts)))

(defn add-parsing-for-multi [option]
  (if (= :multi (:prompt option))
    (assoc option :parse-fn #(str/split % #","))
    option))

(defn preprocess-option [options]
  (-> options
      add-parsing-for-multi))

(defn menu!
  "Options have keys that map to clojure.tools.cli options via [[->cli-tools-option]].

  Custom keys are:

  :prompt one of :text :number :select :multi
  When missing a :prompt key, we will not ask this quesion on the cli menu.
  So if it is required, it must be passed via cli flags.

  :choices - a string seq, or a delay that references a string seq.

  n.b. - a handy trick is to add a bb task like:

  x (prn (menu! (current-task)
         {:id :fav-foods
          :short \"-p\"
          :long \"--port PORT\"
          :prompt :multi
          :choices [\"apple\" \"banana\" \"egg salad\" \"green onions\" \"mango\"]}))

  and call it via running `bb x` in your terminal.


 - to pass values into a :multi :prompt from the cli, seperate them with commas, like so:
   bb mytask --multi a,b,c

  "
  [current-task & options]
  (menu-cli current-task (map preprocess-option options) *command-line-args*))
