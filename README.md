# Big Data Tools on Ubuntu

A practical, step-by-step guide for installing, configuring, testing, and troubleshooting a local Big Data learning environment on Ubuntu.

The guide covers the Hadoop ecosystem, distributed processing, NoSQL databases, data ingestion, event streaming, and the ELK stack.

---

## Table of Contents

- [Overview](#overview)
- [Environment](#environment)
- [Tools](#tools)
- [Installation Order](#installation-order)
- [Directory Layout](#directory-layout)
- [Architecture](#architecture)
- [Important Notes](#important-notes)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## Overview

This repository documents the setup of a local Big Data development and learning environment.

The goal is to provide reproducible installation instructions rather than relying on pre-configured virtual machines or Docker images.

The setup is intended for:

- Big Data coursework
- Hadoop ecosystem labs
- Data engineering practice
- Distributed processing experiments
- NoSQL database practice
- Streaming and messaging practice
- ELK stack experimentation

This is a **single-machine learning environment**, not a production cluster.

---

## Environment

The guide was developed and tested on:

| Component         | Version / Configuration |
| ----------------- | ----------------------- |
| Operating System  | Ubuntu 24.04            |
| Architecture      | x86_64                  |
| Java              | OpenJDK 8 and 17        |
| Installation Root | `/mnt/vol_e/bigdata`    |
| Filesystem        | Linux `ext4`            |

The installation root can be changed if necessary.

For example, if Big Data tools are installed under:

```text
/opt/bigdata
```

the paths in the configuration files should be adjusted accordingly.

---

## Tools

| Tool          |        Version | Purpose                                     |
| ------------- | -------------: | ------------------------------------------- |
| Java          | OpenJDK 8 / 17 | Runtime environment                         |
| Hadoop        |          3.3.6 | Distributed storage and resource management |
| Hive          |            3.x | SQL and data warehousing                    |
| Spark         |          3.5.1 | Distributed data processing                 |
| Flink         |         1.20.2 | Stream and batch processing                 |
| Flume         |         1.11.0 | Data ingestion                              |
| HBase         | 2.5.12-hadoop3 | Distributed NoSQL database                  |
| Sqoop         |          1.4.7 | Relational database ↔ Hadoop transfer       |
| PostgreSQL    |          16.14 | Relational database for testing             |
| Elasticsearch |        8.17.10 | Search and analytics                        |
| Logstash      |        8.17.10 | Data ingestion and processing               |
| Kibana        |        8.17.10 | Visualization                               |
| Kafka         |          3.9.1 | Distributed event streaming                 |

---

## Installation Order

The recommended installation order is:

### Foundation

1. [Prerequisites](docs/00-prerequisites.md)
2. [Hadoop](docs/01-hadoop.md)

### Hadoop Ecosystem

3. [Hive](docs/02-hive.md)
4. [Spark](docs/03-spark.md)
5. [Flink](docs/04-flink.md)
6. [Flume](docs/05-flume.md)
7. [HBase](docs/06-hbase.md)

### Relational Database and Data Transfer

8. [PostgreSQL](docs/12-postgresql.md)
9. [Sqoop](docs/07-sqoop.md)

### ELK Stack

10. [Elasticsearch](docs/08-elasticsearch.md)
11. [Logstash](docs/09-logstash.md)
12. [Kibana](docs/10-kibana.md)

### Streaming

13. [Kafka](docs/11-kafka.md)

### Troubleshooting

14. [Troubleshooting](docs/13-troubleshooting.md)

---

## Directory Layout

The tools are installed under a common directory:

```text
/mnt/vol_e/bigdata/
```

A typical installation looks like:

```text
/mnt/vol_e/bigdata/
├── hadoop-3.3.6/
├── hive/
├── spark/
├── flink/
├── flume/
├── hbase/
├── sqoop/
├── elasticsearch/
├── logstash/
├── kafka/
├── hdfs/
│   ├── namenode/
│   └── datanode/
└── postgresql/
```

The actual directory names may differ slightly depending on the downloaded archive.

---

## Architecture

The resulting learning environment combines several technologies:

```text
                         ┌──────────────┐
                         │ PostgreSQL   │
                         └──────┬───────┘
                                │
                              Sqoop
                                │
                                ▼
┌──────────┐             ┌──────────────┐
│  Flume   │────────────►│     HDFS     │
└──────────┘             └──────┬───────┘
                                │
                  ┌─────────────┼─────────────┐
                  │             │             │
                  ▼             ▼             ▼
                Hive          Spark         Flink
                  │             │             │
                  └─────────────┼─────────────┘
                                │
                              HBase


              ┌──────────────┐
              │    Kafka     │
              │    KRaft     │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │  Logstash    │
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │ Elasticsearch│
              └──────┬───────┘
                     │
                     ▼
              ┌──────────────┐
              │    Kibana    │
              └──────────────┘
```

---

## Important Notes

### This is a learning environment

The setup uses a single Ubuntu machine rather than multiple physical or virtual nodes.

Hadoop therefore runs in pseudo-distributed mode.

This is useful for learning:

- HDFS
- YARN
- MapReduce
- Hive
- Spark
- HBase
- Flink
- Flume
- Sqoop

but does not represent a production cluster.

---

### Java versions

Different tools have different Java compatibility requirements.

This guide therefore uses both Java 8 and Java 17.

In particular:

```text
Hadoop / Hive / HBase
        │
        ▼
      Java 8
```

while newer tools such as Kafka and Elasticsearch can use Java 17 or a bundled JDK.

Always check the individual tool's guide before changing `JAVA_HOME`.

---

### Installation location

The guide assumes:

```bash
BIGDATA_HOME=/mnt/vol_e/bigdata
```

Using a dedicated partition can prevent large Hadoop, Kafka, and Elasticsearch data directories from filling the Ubuntu root filesystem.

---

## Verification

After completing the installation, the following commands can be used to verify the tools:

```bash
java -version

hadoop version

hive --version

spark-submit --version

flink --version

flume-ng version

hbase version

sqoop version

psql --version

elasticsearch --version

logstash --version

kafka-topics.sh --version
```

For Hadoop and HBase Java processes:

```bash
jps
```

Typical Hadoop output:

```text
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
```

Typical HBase additions:

```text
HMaster
HRegionServer
HQuorumPeer
```

---

## Troubleshooting

Common issues encountered during the setup are documented in:

[docs/13-troubleshooting.md](docs/13-troubleshooting.md)

The troubleshooting guide covers:

- Java version conflicts
- `JAVA_HOME` problems
- Hadoop daemon startup failures
- HDFS permissions
- YARN configuration
- Spark/YARN configuration
- Flink/HDFS integration
- HBase RegionServer issues
- Sqoop JDBC problems
- PostgreSQL SCRAM authentication
- Commons Lang dependency conflicts
- Elasticsearch 8 mapping changes
- Kibana Data Views
- Kafka KRaft storage formatting
- Port conflicts
- stale processes

---

## Useful Commands

### Check Java

```bash
java -version
echo $JAVA_HOME
```

### Check installed commands

```bash
which hadoop
which hive
which spark-submit
which flink
which flume-ng
which hbase
which sqoop
which elasticsearch
which logstash
which kafka-topics.sh
```

### Check running Java services

```bash
jps
```

### Check HDFS

```bash
hdfs dfs -ls /
```

### Check YARN

```bash
yarn node -list
```

### Check HBase

```bash
hbase shell
```

Then:

```text
status 'simple'
```

---

## Contributing

This repository is primarily a personal learning guide, but improvements are welcome.

When adding a tool:

1. Document the exact version.
2. Include the download command.
3. Include the extraction/install command.
4. Document required environment variables.
5. Document configuration files and their contents.
6. Include startup and shutdown commands.
7. Include verification commands.
8. Include at least one functional test.
9. Document common errors and their fixes.
10. Never commit credentials or generated data.

---

## License

This repository contains installation instructions and configuration examples for publicly available software.

Each tool remains subject to its own license.
