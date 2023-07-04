docker-compose exec -T ksqldb-cli ksql http://ksqldb-server:8088 <<-EOF
    show topics;

    set 'commit.interval.ms'='2000';
    set 'cache.max.bytes.buffering'='10000000';
    set 'auto.offset.reset'='earliest';
    set 'ksql.streams.replication.factor'='1';

    CREATE STREAM consumer_src(_id string, firstname string, lastname string, familymembers string) WITH (KAFKA_TOPIC='demo.globalplay-preprod.consumers', VALUE_FORMAT='json');

    CREATE OR REPLACE STREAM CONSUMER_SRC_REKEY WITH (PARTITIONS=1) AS \ SELECT * FROM consumer_src PARTITION BY _id;

    CREATE TABLE consumer_tbl (_ID STRING PRIMARY KEY, FIRSTNAME STRING, LASTNAME STRING)\ WITH (KAFKA_TOPIC='CONSUMER_SRC_REKEY', VALUE_FORMAT='json');

    CREATE OR REPLACE TABLE class_boost WITH(KAFKA_TOPIC='demo.class.temp',VALUE_FORMAT='AVRO') AS SELECT * FROM consumer_tbl;
EOF

    alter stream consumer_src add column email string;

    CREATE OR REPLACE STREAM CONSUMER_SRC_REKEY WITH (PARTITIONS=1) AS \ SELECT * FROM consumer_src PARTITION BY _id;

    alter table consumer_tbl add column email string;

    CREATE OR REPLACE TABLE class_boost WITH(KAFKA_TOPIC='demo.class.class_boost',VALUE_FORMAT='AVRO') AS SELECT * FROM consumer_tbl;


CREATE STREAM payment_report_stream(    
    _id varchar, 
    familyMember varchar,
    isMainMember BOOLEAN,
    totalTicket INT,
    retref varchar,
    account varchar,
    authcode varchar,
    batchid varchar,
    acctid varchar,
    transactionType varchar,
    amount DOUBLE,
    convenienceFees DOUBLE,
    dcCardFees DOUBLE,
    totalAmount DOUBLE,
    paidGlobalPlayCash DOUBLE,
    accttype varchar,
    createdAt TIMESTAMP,
    updatedAt TIMESTAMP,                                                  
    error varchar,
    metadata STRUCT< billingEmail varchar>,
    isRefunded BOOLEAN,
    invoiceNumber varchar,
    chargeFailed BOOLEAN,
    activationFees DOUBLE,
    invoiceData MAP<varchar,
    STRUCT<
        _id varchar,
        memberId varchar, 
        createdAt timestamp,
        packageId varchar,
        type varchar,
        amount double,
        remainMembership double,
        membershipSlotId varchar,
        trialCode varchar,
        isTrial boolean,
        purveyorId varchar>>,
    __deleted BOOLEAN
 ) WITH (KAFKA_TOPIC='demo.globalplay-preprod.payment-reports', VALUE_FORMAT='json');