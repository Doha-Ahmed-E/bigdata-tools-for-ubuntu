#!/usr/bin/env bash

set -e

BIGDATA_HOME="${BIGDATA_HOME:-/mnt/vol_e/bigdata}"

echo " Big Data Directory Setup"
echo "BIGDATA_HOME: $BIGDATA_HOME"
echo

mkdir -p "$BIGDATA_HOME"

# Hadoop / HDFS
mkdir -p "$BIGDATA_HOME/hdfs/namenode"
mkdir -p "$BIGDATA_HOME/hdfs/datanode"

# Tool installation directories
mkdir -p "$BIGDATA_HOME/hadoop"
mkdir -p "$BIGDATA_HOME/hive"
mkdir -p "$BIGDATA_HOME/spark"
mkdir -p "$BIGDATA_HOME/flink"
mkdir -p "$BIGDATA_HOME/flume"
mkdir -p "$BIGDATA_HOME/hbase"
mkdir -p "$BIGDATA_HOME/sqoop"
mkdir -p "$BIGDATA_HOME/elasticsearch"
mkdir -p "$BIGDATA_HOME/logstash"
mkdir -p "$BIGDATA_HOME/kafka"
mkdir -p "$BIGDATA_HOME/postgresql"

echo "Directory structure:"
echo

find "$BIGDATA_HOME" -maxdepth 2 -type d | sort

echo
echo "Directory setup complete."