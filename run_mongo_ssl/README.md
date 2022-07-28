# MongoDB with and without SSL support

Make sure that you have docker running.

There is a script in the main metabase repository at `test_resources/ssl/mongo`.
In that folder execute `run-server.sh -h` to see your options.

## Running the Metabase tests

If you are running Mongo with SSL, you can execute the tests with

```sh
MB_TEST_MONGO_REQUIRES_SSL=1 DRIVERS=mongo clojure -X:dev:drivers:drivers-dev:test
```

Execute the following if Mongo does not require SSL:

```sh
MB_TEST_MONGO_REQUIRES_SSL=0 DRIVERS=mongo clojure -X:dev:drivers:drivers-dev:test
```

## Using Mongo for other purposes

The certificates needed for the connection are stored in `test_resources/ssl/mongo`.
the user name and the password can be found in
`modules/drivers/mongo/test/metabase/test/data/mongo.clj`
