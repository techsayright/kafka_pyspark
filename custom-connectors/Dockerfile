FROM confluentinc/cp-kafka-connect-base

RUN confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:latest \
    && confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:latest \
    && confluent-hub install --no-prompt confluentinc/kafka-connect-aws-redshift:latest \
    && confluent-hub install --no-prompt debezium/debezium-connector-mongodb:latest

ADD  redshift-jdbc42-2.1.0.16.jar /usr/share/confluent-hub-components/confluentinc-kafka-connect-jdbc

ADD connectors /etc/kafka-connect/connectors

WORKDIR /etc/kafka-connect/connectors

CMD ["./register_connectors.sh"]



