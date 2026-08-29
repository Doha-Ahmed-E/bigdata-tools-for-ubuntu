#!/usr/bin/env bash

echo " Big Data Installation Verification"
echo "------------------------------------------"


check_command() {
    local name="$1"
    local command="$2"

    printf "%-20s" "$name"

    if command -v "$command" >/dev/null 2>&1; then
        echo "FOUND"
    else
        echo "NOT FOUND"
    fi
}

echo "Commands"
echo "------------------------------------------"

check_command "Java" java
check_command "Hadoop" hadoop
check_command "HDFS" hdfs
check_command "YARN" yarn
check_command "Hive" hive
check_command "Spark" spark-submit
check_command "Flink" flink
check_command "Flume" flume-ng
check_command "HBase" hbase
check_command "Sqoop" sqoop
check_command "PostgreSQL" psql
check_command "Elasticsearch" elasticsearch
check_command "Logstash" logstash
check_command "Kafka" kafka-topics.sh

echo
echo "Environment Variables"
echo "------------------------------------------"

for variable in \
    JAVA_HOME \
    HADOOP_HOME \
    HADOOP_CONF_DIR \
    YARN_CONF_DIR \
    HIVE_HOME \
    SPARK_HOME \
    FLINK_HOME \
    FLUME_HOME \
    HBASE_HOME \
    SQOOP_HOME \
    ELASTICSEARCH_HOME \
    LOGSTASH_HOME \
    KAFKA_HOME
do
    printf "%-20s %s\n" "$variable" "${!variable:-NOT SET}"
done

echo
echo "Running Java Processes"
echo "------------------------------------------"

if command -v jps >/dev/null 2>&1; then
    jps
else
    echo "jps not found"
fi

echo
echo "Verification complete."