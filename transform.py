from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("KafkaStreamingDemo") \
    .config("spark.jars.packages", "org.apache.spark:spark-sql-kafka-0-10_2.12:3.4.0") \
    .getOrCreate()

TOPIC_NAME = 'demo.globalplay-preprod.payment-reports'
df = spark \
    .readStream \
    .format("kafka") \
    .option("kafka.bootstrap.servers", "localhost:9092,localhost:9093,localhost:9094") \
    .option("startingOffsets", "earliest") \
    .option("subscribe", TOPIC_NAME) \
    .load()

df.selectExpr("CAST(key AS STRING)", "CAST(value AS STRING)") \
    .writeStream \
    .format("console") \
    .start() \
    .awaitTermination()
