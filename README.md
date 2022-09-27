Scripts that make local Metabase development handier. Currently these only consist of scripts for running different
databases we support like MySQL or Spark SQL locally, but we can add scripts for other stuff in the future if we think
of anything good.

Please feel free to collaborate and improve these scripts or add new ones!

### bb tasks

To get setup you'll need:

- *babashka* `brew install borkdude/brew/babashka`
- *npm* `brew install npm`

To see a list of avaliable tasks, run:

    bb tasks
    
for help with a task, use `-h` or `--help`.

    bb download-and-run-jar --help
    
``` shell
  Download and run a jar for a branch, and run it on a port

 -b --branch BRANCH
┌────────────┬─────────────────────────────────────────╖
│ key        │ value                                   ║
├────────────┼─────────────────────────────────────────╢
│ :id        │ :branch                                 ║
│ :title     │ What branch would you like to use?      ║
│ :required? │ true                                    ║
│ :options   │ sci.impl.fns$fun$arity_0__3527@2471695a ║
│ :prompt    │ :autocomplete                           ║
╘════════════╧═════════════════════════════════════════╝

 -p --port PORT
┌────────────┬─────────────────────────────────────╖
│ key        │ value                               ║
├────────────┼─────────────────────────────────────╢
│ :id        │ :port                               ║
│ :title     │ What port would you like to run on? ║
│ :required? │ true                                ║
│ :prompt    │ :numeral                            ║
╘════════════╧═════════════════════════════════════╝

 -s --socket-repl SOCKETPORT
┌────────────┬─────────────────────────────────╖
│ key        │ value                           ║
├────────────┼─────────────────────────────────╢
│ :id        │ :socket-repl                    ║
│ :title     │ Run metabase with a socket repl ║
│ :prompt    │ :confirm                        ║
│ :cli-only? │ true                            ║
╘════════════╧═════════════════════════════════╝
```


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
