FROM metabase/metabase-enterprise:v1.44.3

ADD groupSetup.sh .
RUN sh groupSetup.sh

ADD https://download.oracle.com/otn-pub/otn_software/jdbc/217/ojdbc11.jar /plugins/oracle.metabase-driver.jar

RUN chown metabase:metabase /plugins/oracle.metabase-driver.jar