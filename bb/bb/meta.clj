(ns bb.meta
  (:require [bb.tasks :as t]
            [bask.colors :as c]
            [clojure.string :as str]
            [babashka.wait :as wait]
            [babashka.process :refer [shell]]))

(defn build [app-db user-name password extensions]
  (let [listen-for-nrepl-and-init! (fn listen-for-nrepl-and-init! []
                                     (let [nrepl-path (str (t/env "MB_DIR") "/.nrepl-port")]
                                       (println (c/green "[bb metabuild] Waiting to initialize nrepl..."))
                                       (let [nrepl-port (parse-long (slurp nrepl-path))]
                                         (let [nrepl-port (parse-long (slurp (str (t/env "MB_DIR") "/.nrepl-port")))]
                                           (println (c/green "[bb metabuild] initializing dev repl..."))
                                           (println (c/green (t/nrepl-eval nrepl-port "(do (in-ns 'user) (dev) (start!) ::started!)")))))))
        env+ (assoc (t/env) "MB_DB_CONNECTION_URI" (case app-db
                                                     "postgres" (str "postgres://" user-name ":" password "@localhost:5432/metabase")
                                                     "mysql" (str "mysql://" user-name ":" password "@localhost:3306/metabase")
                                                     "h2" "" ))
        cmd (str "clj -M" (str/join (map (fn [s-or-kw] (keyword (name s-or-kw))) extensions)))]
    (println (:out (shell {:out :string} "java -version")))
    (t/print-env "mb" env+)
    (println (c/green "\n--- Starting metabase with: -----\n"))
    (println (c/green cmd))
    (println (c/green "\n---------------------------------\n"))
    (when (not= (t/env "MB_DIR") (:out (deref (shell {:out :string} "pwd"))))
      (c/magenta "In directory: " (t/env "MB_DIR")))
    (future (listen-for-nrepl-and-init!))
    (shell {:extra-env env+ :dir (t/env "MB_DIR")} cmd)))
