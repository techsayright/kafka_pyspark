docker-compose exec -T ksqldb-cli ksql http://ksqldb-server:8088 <<-EOF
    show topics;

    set 'commit.interval.ms'='2000';
    set 'cache.max.bytes.buffering'='10000000';
    set 'auto.offset.reset'='earliest';
    set 'ksql.streams.replication.factor'='1';

    CREATE OR REPLACE STREAM transactions_stream1 WITH (PARTITIONS=1, KAFKA_TOPIC='funfull.ff.transactions', VALUE_FORMAT='avro')  AS 
    SELECT 
        ifnull(cast(map_values(transform(json_records(totalMembers), (k,v) => k, (k,v) => concat('"', v, '"'))) as string), '[]') AS total_members,
        ifnull(cast(map_values(transform(json_records(cancelMembers), (k,v) => k, (k,v) => concat('"', v, '"'))) as string), '[]') AS cancel_members
    from transactions_stream ;


    CREATE STREAM e_giftcard_purveyors(
    _id VARCHAR, 
    brandName varchar,
    type varchar,
    denominations varchar,
    discountTier1InPercentage double,
    discountTier2InPercentage double,
    feeInUSD double,
    categories varchar,
    brandId varchar,
    disclaimers varchar,
    giftCardType varchar,
    longDescriptions varchar,
    redemptionNote varchar,
    shortDescriptions varchar,
    term varchar,
    updatedAt timestamp,
    website varchar,
    images varchar,
    logo varchar,
    originalDenominations varchar,
    isActive boolean,
    isOnlyOnline boolean,
    nameList varchar 
    ) WITH (KAFKA_TOPIC='demo.globalplay-preprod.e-giftcard-purveyors', VALUE_FORMAT='json');

    CREATE OR REPLACE STREAM suspend_consumers_membersaddedat_stream WITH (PARTITIONS=1) AS \ SELECT 
    _id as suspend_acc_doc_id,
    explode(MAP_VALUES(membersAddedAt)) -> _id as memberaddedat_id,
    explode(MAP_VALUES(membersAddedAt)) -> memberId as member_id,
    explode(MAP_VALUES(membersAddedAt)) -> membershipType as membership_type,
    explode(MAP_VALUES(membersAddedAt)) -> suspendFrom as suspend_from,
    explode(MAP_VALUES(membersAddedAt)) -> createdAt as date_created,
    rowtime as row_time
    FROM suspend_consumers_stream;

    CREATE OR REPLACE STREAM suspend_consumers_membersaddedat_stream1 WITH (PARTITIONS=1, KAFKA_TOPIC='funfull.ff.suspend_acnt_memberaddedat', VALUE_FORMAT='avro') AS \ SELECT *
    FROM suspend_consumers_membersaddedat_stream PARTITION by _id;


EOF
    CREATE OR REPLACE STREAM CONSUMER_SRC_REKEY WITH (PARTITIONS=1) AS \ SELECT * FROM consumer_src PARTITION BY _id;

    CREATE TABLE consumer_tbl (_ID STRING PRIMARY KEY, FIRSTNAME STRING, LASTNAME STRING)\ WITH (KAFKA_TOPIC='CONSUMER_SRC_REKEY', VALUE_FORMAT='json');

    CREATE OR REPLACE TABLE class_boost WITH(KAFKA_TOPIC='demo.class.class_boost',VALUE_FORMAT='AVRO') AS SELECT * FROM consumer_tbl;



CREATE STREAM checkin_stream18(
    _id VARCHAR,
    guest STRUCT<checkedInCount int,
    count int>,
    isMainMemberCheckedIn BOOLEAN,
    ticketHTMLs STRING,
    typeOfCheckin varchar,
    isDeleted BOOLEAN,
    isCancelled BOOLEAN,
    refundedTicket int,
    isSharedCheckin BOOLEAN,
    businessId varchar,
    checkInType varchar,
    isMainMember BOOLEAN,
    totalCost double,
    ticketUsed int,
    uniqueCodeOrTicket varchar,
    consumer varchar,
    paymentReport varchar,
    perMemberCost double,
    perMemberTicket double,
    perNonMemberCost double
) WITH (KAFKA_TOPIC='demo.globalplay-prod.check-ins', VALUE_FORMAT='json');

select count(*) from checkin_stream18 emit changes;

docker-compose --env-file .env up