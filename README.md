Scripts that make local Metabase development handier. Currently these only consist of scripts for running different
databases we support like MySQL or Spark SQL locally, but we can add scripts for other stuff in the future if we think
of anything good.

### bb tasks

To get setup you'll need:

- *babashka* `brew install borkdude/brew/babashka`
- *fzf* `brew install fzf`

To see a list of avaliable tasks, run:

    bb tasks

#### Setup MB_DIR

    MB_DIR=/path/to/metabase

#### How to get help

for help with a task, use `-h` or `--help`.

    bb run-branch --help

#### Using metabuild with vscode

To start repl that you can connect to from Visual Studio Code you can use following alias instead of the default `:nrepl`.

`~/.clojure/deps.edn`
```
{:aliases
 {:vsc {:extra-deps {nrepl/nrepl {:mvn/version,"1.0.0"}
                     cider/cider-nrepl {:mvn/version,"0.28.5"}}
        :main-opts ["-m" "nrepl.cmdline"
                    "--middleware" "[cider.nrepl/cider-middleware]"]}}}
```

Your startup command could then look as following:
`bb metabuild -d postgres -e dev:ee:ee-dev:drivers:drivers-dev:vsc`

If you are running the app db in docker container from images in this repo you need to pass in also the correct credentials, eg. `MB_JETTY_PORT=10001 MB_DIR=path/to/your/mb/repo bb --config /path/to/this/repo/bb.edn metabuild -d postgres -u metabase -p Password1234 -e dev:ee:ee-dev:drivers:drivers-dev:vsc`

#### Passing

### Database Scripts

These scripts run the same Docker images with the same env vars we use in CI and then dump out some useful info for
using them. They also nuke the existing image when you run the script a second time so you can just run it again to
completely reset the DB e.g. when running tests.

```bash
$ ~/mb-scripts/run-mariadb-latest.sh
Removing existing container...
maria-db-latest
Nothing to remove
73003b822d25aaf5b55f739f9b91f94f7f8d16a5abbd43b76fb2d34116d49ceb
Started MariaDB latest on port 3306.

jdbc:mysql://localhost:3306/metabase_test?user=root

MB_DB_TYPE=mysql MB_DB_DBNAME=metabase_test MB_DB_HOST=localhost MB_DB_PASS='' MB_DB_PORT=3306 MB_DB_USER=root MB_MYSQL_TEST_USER=root

mysql --user=root --host=127.0.0.1 --port=3306 --database=metabase_test
```

You need to have Docker installed to use these scripts!

#### For Macbook with ARM chips
Some drivers like oracle, vertica, sqlserver, mysql (and possibly more) are currently not able to run on Apple M chips.
The work around is using colima:
1. [Install](https://github.com/abiosoft/colima#getting-started) colima
2. Start it with `colima start --arch x86_64 --memory 4`
3. Start the database with scripts like normal

##### Colima in Feb 2025
If colima is not starting for you on m2 mac, looking into the issue https://github.com/abiosoft/colima/issues/1248
could help.

#### Presto on Macbook with ARM chips

Rather than use Docker, you can run Presto with Postgres with the following steps:
- Follow [these
  steps](https://prestodb.io/docs/current/installation/deploy-brew.html#deploy-presto-on-an-apple-silicon-mac-using-homebrew)
  to install presto using homebrew
- Add a properties file for postgresql in `/usr/local/Cellar/prestodb/<version>/libexec/etc/catalog`, called
  `test_data.properties` (`test_data` is the catalog name) with the following contents:
  ```
  connector.name=postgresql
  connection-url=jdbc:postgresql://localhost:5432/test_data
  connection-user=<mb-postgresql-test-user>
  connection-password=<mb-postgresql-test-password>
  ```
- To run the presto-jdbc driver tests, you'll need to create a database `test_data` on the postgres server that <mb-postgresql-test-user> has all privileges to, and create a schema in the database named "default".
- Start the presto server with `/usr/local/opt/prestodb/bin/presto-server run`

Alternatively, Luis has created a [Link](https://github.com/paoliniluis/metabase-presto-and-trino) for testing Presto and Trino with Docker that might work too.

# Automated setup

In stacks->setup-container you'll find a Compose file that has a Metabase container along with a setup container. The setup container waits till the Metabase container is ready (status:ok in the health endpoint) and then sets up a user (a@b as the user/ metabot1 as the password). You can tweak the script as much as you want.

# Metabase in HA (highly-available mode)

This stack is to test how Metabase behaves in HA mode, so you'll have a configuration like the following:

```
--------------
|   HAProxy  |
--------------
    |     |
------  ------
| MB |  | MB |
------  ------
    |    |
--------------
|  Postgres  |
--------------
```

HAProxy is configured to balance requests in a round-robin manner and it checks the health of the application (so you can also simulate a failure)

This will allow you to test how Metabase behaves when it scales horizontally, both on the FE (showing things like the process picker in the troubleshooting -> logs section) and on the backend (health checks, queues, settings, etc). All configs in the LB can be changed from the config in stacks/ha/config/haproxy.cfg

# Downloading Jars

`mb-download` will let you download a jar to a given path or straight into `$JARS`.

``` bash
$ ./mb-download -h
Usage: mb-download 0.42.2
Usage: mb-download 1.45.2
Usage: mb-download 1.45.2 ~/path/to/my/jars

protip: this script will read from $JARS, and use that as your jar directory.
```

