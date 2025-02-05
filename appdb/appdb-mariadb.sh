env vars: MB_DB_TYPE=mysql MB_DB_DBNAME=metabase_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3306 MB_DB_USER=root MB_MYSQL_TEST_USER=root

Clojure CLI:

clojure -J-Dmb.db-type=mysql -J-Dmb.db-port=3306 -J-Dmb.db.dbname=metabase_test -J-Dmb.db.user=root -J-Dmb.db.pass=''

or add a profile for it to your ~/.clojure/deps.edn:

{:profiles
 {:user/mysql
  {:jvm-opts
   ["-Dmb.db-type=mysql"
    "-Dmb.db-port=3306"
    "-Dmb.db.dbname=metabase_test"
    "-Dmb.db.user=root"
    "-Dmb.db.pass="]}}}
