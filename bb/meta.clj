(ns bb.meta
  (:require [bb.tasks :as t]
            [bask.colors :as c]
            [clojure.string :as str]
            [babashka.wait :as wait]
            [babashka.fs :as fs]
            [babashka.process :refer [shell]]))

(defn- listen-for-nrepl-and-init! []
  (let [nrepl-path (str (t/env "MB_DIR") "/.nrepl-port")
        _ (fs/delete-if-exists nrepl-path)
        _ (println (c/green "[bb metabuild] 👀 watching for .nrepl-port file to be posted at" nrepl-path "..."))
        _ (println (c/magenta "[bb metabuild] 🚸 Path: " (pr-str (update
                                                                (wait/wait-for-path nrepl-path)
                                                                :took #(str % " ms")))))
        nrepl-port (parse-long (slurp nrepl-path))
        _ (println (c/green "[bb metabuild] 📱 Waiting for nrepl-port to open ..."))
        _ (println (c/magenta "[bb metabuild] 📲 Port: " (pr-str (update (wait/wait-for-port "localhost" nrepl-port) :took #(str % " ms")))))
        repl-cmd "(do (in-ns 'user) (dev) (start!) ::started!)"]
    (println (c/green "[bb metabuild] 🔛 initializing dev repl with '" repl-cmd "' ..."))
    (println (c/green "[bb metabuild] 🔁 " (t/nrepl-eval nrepl-port repl-cmd)))
    (println (c/green "[bb metabuild] ✅ Done."))))

(defn app-db-connection-str [app-db user-name password db-name db-port]
  (if (= "h2" app-db)
    ""
    (let [;; scheme = mysql or postgres
          scheme app-db
          password-part (when (seq password) (str ":" password))
          db-port (or db-port (case app-db "mysql" 3306 "postgres" 5432))
          db-name (or db-name (case app-db "mysql" "metabase_test" "postgres" "metabase"))]
      (str scheme "://" user-name password-part "@localhost:" db-port "/" db-name))))

(defn build [app-db user-name password extensions db-name db-port]
  (let [env+ (assoc (t/env)
                    "MB_DB_CONNECTION_URI"
                    (or (t/env "FORCE_MB_DB_CONNECTION_URI" (constantly false))
                        (app-db-connection-str app-db user-name password db-name db-port))
                    "MB_DB_TYPE" app-db)
        cmd (str "clj -M" (str/join (map (fn [s-or-kw] (keyword (name s-or-kw))) extensions)))]
    (println (:out (shell {:out :string} "java -version")))
    (t/print-env "mb" env+)
    (println (c/green "\n  ==== Starting Metabase with: ====  \n"))
    (println (c/green cmd))
    (println (c/green "\n  =================================  \n"))
    (println (c/magenta "In directory 📂:" (t/env "MB_DIR")))
    (future (listen-for-nrepl-and-init!))
    (shell {:extra-env env+ :dir (t/env "MB_DIR")} cmd)))
