#! /usr/bin/env bash

SOURCE_DIR=`dirname "${BASH_SOURCE[0]}"`

source "$SOURCE_DIR/env-presto.sh"

source "$SOURCE_DIR/common.sh"

kill-existing ${CONTAINER_NAME}

docker run -p ${HOST_PORT}:8080 \
       -p 8443:8443 \
       --name ${CONTAINER_NAME} \
       --hostname presto \
       --rm \
       -d prestodb/presto:${PRESTO_VERSION}

cat << EOF

Started Presto on port ${HOST_PORT} (insecure HTTP) and port 8443 (secure HTTPS) on the host machine

To make the self signed certificate that was generated for this Presto instance available to your Java application
(ex: Metabase), perform the following steps after Presto is completely online.  You can run

  docker logs --tail 5 ${CONTAINER_NAME}

to see the current output.  Once Presto is online, you will see a line containing something like the following:

  ======== SERVER STARTED ========

Now you can capture the certificate.  You will need to have openssl on your PATH, and
also have the JAVA_HOME env var set for this all to work.

  # capture the server cert in PEM format
  openssl s_client -connect localhost:8443 2>/dev/null </dev/null |  sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > $SERVER_CA_PEM_FILE
  # convert it to DER format to import into the keystore
  openssl x509 -outform der -in $SERVER_CA_PEM_FILE -out $SERVER_CA_DER_FILE
  # create a copy of the default cacerts (trust store)
  cp \$JAVA_HOME/lib/security/cacerts $MODIFIED_CACERTS_FILE
  # import the DER certificate into this trust store
  keytool -noprompt -import -alias presto -keystore $MODIFIED_CACERTS_FILE -storepass changeit -file $SERVER_CA_DER_FILE -trustcacerts

Finally, this can be made available to Metabase by adding the following JVM args when starting:

  -Djavax.net.ssl.trustStore=$MODIFIED_CACERTS_FILE -Djavax.net.ssl.trustStorePassword=changeit

EOF

print-presto-vars
