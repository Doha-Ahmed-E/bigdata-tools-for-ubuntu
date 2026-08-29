# Apache Kafka 3.9.1 on Ubuntu 24.04

This guide explains how to install, configure, run, and test Apache Kafka 3.9.1 on Ubuntu 24.04.

The setup uses **KRaft mode**, so ZooKeeper is not required.

## Environment

| Component | Version |
|---|---|
| OS | Ubuntu 24.04 |
| Java | OpenJDK 17 |
| Kafka | 3.9.1 |
| Kafka mode | KRaft |
| Installation directory | `/mnt/vol_e/bigdata/kafka/kafka_2.13-3.9.1` |
| Kafka data directory | `/mnt/vol_e/bigdata/kafka/data` |

The installation is placed on `/mnt/vol_e` rather than the Ubuntu root partition.

---

# 1. Prerequisites

Kafka 3.9.1 requires Java.

Check the installed Java version:

```bash
java -version
```

Check `JAVA_HOME`:

```bash
echo $JAVA_HOME
```

The expected Java installation in this setup is:

```text
/usr/lib/jvm/java-17-openjdk-amd64
```

If Java 17 is not installed:

```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

Then verify:

```bash
java -version
```

---

# 2. Create the Kafka Installation Directory

Create a directory for Kafka under the Big Data tools directory:

```bash
cd /mnt/vol_e/bigdata
mkdir -p kafka
cd kafka
```

---

# 3. Download Apache Kafka

Download Kafka 3.9.1:

```bash
wget https://downloads.apache.org/kafka/3.9.1/kafka_2.13-3.9.1.tgz
```

If the Apache mirror is unavailable, the archive can also be downloaded from the Apache Kafka archive:

```bash
wget https://archive.apache.org/dist/kafka/3.9.1/kafka_2.13-3.9.1.tgz
```

Verify that the archive exists:

```bash
ls -lh kafka_2.13-3.9.1.tgz
```

---

# 4. Extract Kafka

Extract the archive:

```bash
tar -xzf kafka_2.13-3.9.1.tgz
```

Verify:

```bash
ls
```

The extracted directory should be:

```text
kafka_2.13-3.9.1
```

The final installation path is:

```text
/mnt/vol_e/bigdata/kafka/kafka_2.13-3.9.1
```

---

# 5. Configure Environment Variables

Set `KAFKA_HOME`:

```bash
export KAFKA_HOME=/mnt/vol_e/bigdata/kafka/kafka_2.13-3.9.1
```

Add Kafka's `bin` directory to `PATH`:

```bash
export PATH=$KAFKA_HOME/bin:$PATH
```

Verify:

```bash
echo $KAFKA_HOME
```

Expected:

```text
/mnt/vol_e/bigdata/kafka/kafka_2.13-3.9.1
```

Verify Kafka commands:

```bash
which kafka-server-start.sh
```

Expected:

```text
/mnt/vol_e/bigdata/kafka/kafka_2.13-3.9.1/bin/kafka-server-start.sh
```

Check the Kafka version:

```bash
kafka-server-start.sh --version
```

Expected:

```text
3.9.1
```

## Make the variables persistent

Open the shell configuration:

```bash
nano ~/.bashrc
```

Add:

```bash
export KAFKA_HOME=/mnt/vol_e/bigdata/kafka/kafka_2.13-3.9.1
export PATH=$KAFKA_HOME/bin:$PATH
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $KAFKA_HOME
which kafka-server-start.sh
```

---

# 6. KRaft Mode

Kafka can operate using KRaft instead of ZooKeeper.

KRaft means **Kafka Raft Metadata Mode**.

For this setup:

```text
Kafka
  │
  └── KRaft
       └── No ZooKeeper required
```

The KRaft configuration used by Kafka is:

```text
$KAFKA_HOME/config/kraft/server.properties
```

---

# 7. Configure Kafka Storage

Kafka requires its storage directory to be formatted before the first startup.

The configuration uses:

```text
/mnt/vol_e/bigdata/kafka/data
```

Check the configured log directory:

```bash
grep '^log.dirs' $KAFKA_HOME/config/kraft/server.properties
```

It should point to:

```text
/mnt/vol_e/bigdata/kafka/data
```

If necessary, create the directory:

```bash
mkdir -p /mnt/vol_e/bigdata/kafka/data
```

---

# 8. Generate a Kafka Cluster ID

Generate a cluster ID:

```bash
$KAFKA_HOME/bin/kafka-storage.sh random-uuid
```

Example output:

```text
dhyES3qTQEmEzrf7V8Goxg
```

The value will be different on each installation.

Copy the generated ID.

---

# 9. Format Kafka Storage

Use the generated cluster ID to format the Kafka storage:

```bash
$KAFKA_HOME/bin/kafka-storage.sh format \
-t YOUR_GENERATED_CLUSTER_ID \
-c $KAFKA_HOME/config/kraft/server.properties
```

For example:

```bash
$KAFKA_HOME/bin/kafka-storage.sh format \
-t dhyES3qTQEmEzrf7V8Goxg \
-c $KAFKA_HOME/config/kraft/server.properties
```

A successful format produces output similar to:

```text
Formatting metadata directory ... with metadata.version 3.9-IV0.
```

---

# 10. Important: Do Not Use the Placeholder Literally

The following is only an example:

```bash
-t YOUR_GENERATED_CLUSTER_ID
```

Do **not** enter the text `YOUR_GENERATED_CLUSTER_ID`.

Generate an actual ID first:

```bash
$KAFKA_HOME/bin/kafka-storage.sh random-uuid
```

Then use the returned value.

### Example of an incorrect command

```bash
$KAFKA_HOME/bin/kafka-storage.sh format \
-t YOUR_UUID_HERE \
-c $KAFKA_HOME/config/kraft/server.properties
```

If this is accidentally executed, Kafka may create metadata containing:

```text
YOUR_UUID_HERE
```

and a later attempt using the real UUID can fail with:

```text
Invalid cluster.id
Expected <new-id>, but read YOUR_UUID_HERE
```

---

# 11. Recovering From an Incorrect Initial Format

If Kafka has just been configured and no useful Kafka data exists yet, the simplest solution is to remove the incorrectly formatted data directory.

**Do not do this on an existing Kafka installation containing data you need.**

For a fresh learning installation:

```bash
rm -rf /mnt/vol_e/bigdata/kafka/data/*
```

Generate a new cluster ID:

```bash
$KAFKA_HOME/bin/kafka-storage.sh random-uuid
```

Then format the storage again:

```bash
$KAFKA_HOME/bin/kafka-storage.sh format \
-t YOUR_GENERATED_CLUSTER_ID \
-c $KAFKA_HOME/config/kraft/server.properties
```

---

# 12. Start Kafka

Start Kafka using the KRaft configuration:

```bash
$KAFKA_HOME/bin/kafka-server-start.sh \
$KAFKA_HOME/config/kraft/server.properties
```

Kafka will remain attached to the terminal and display its logs.

A successful startup should eventually show messages indicating that the Kafka server has started.

---

# 13. Create a Kafka Startup Alias

The startup command is long, so an alias can make it easier to start Kafka.

Open:

```bash
nano ~/.bashrc
```

Add:

```bash
alias kafka-start='$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/kraft/server.properties'
```

Reload the shell:

```bash
source ~/.bashrc
```

Kafka can now be started with:

```bash
kafka-start
```

---

# 14. Verify Kafka Is Running

Keep Kafka running in one terminal.

Open another terminal and verify the Kafka process:

```bash
jps
```

Kafka should appear among the running Java processes.

You can also check the Kafka port:

```bash
ss -ltnp | grep 9092
```

The default Kafka client port is:

```text
9092
```

---

# 15. Create a Topic

Create a test topic:

```bash
kafka-topics.sh \
--create \
--topic test-topic \
--bootstrap-server localhost:9092
```

Expected output:

```text
Created topic test-topic.
```

---

# 16. List Topics

List all Kafka topics:

```bash
kafka-topics.sh \
--list \
--bootstrap-server localhost:9092
```

Expected:

```text
test-topic
```

---

# 17. Describe a Topic

Inspect the topic:

```bash
kafka-topics.sh \
--describe \
--topic test-topic \
--bootstrap-server localhost:9092
```

This displays information such as:

* topic name
* partition count
* replication factor
* leader
* replicas
* in-sync replicas

For a single-node learning setup, the replication factor is normally:

```text
1
```

---

# 18. Start a Kafka Producer

Start a producer:

```bash
kafka-console-producer.sh \
--topic test-topic \
--bootstrap-server localhost:9092
```

The terminal will wait for messages.

Enter messages such as:

```text
Hello Kafka
This is my first Kafka message
Kafka is working
```

Each line is sent as a separate Kafka message.

---

# 19. Start a Kafka Consumer

Open another terminal.

Start a consumer:

```bash
kafka-console-consumer.sh \
--topic test-topic \
--bootstrap-server localhost:9092 \
--from-beginning
```

The consumer should display the messages produced earlier:

```text
Hello Kafka
This is my first Kafka message
Kafka is working
```

This confirms that Kafka can:

```text
Producer
   │
   ▼
Kafka Topic
   │
   ▼
Consumer
```

---

# 20. Test Real-Time Message Delivery

Keep the consumer running:

```bash
kafka-console-consumer.sh \
--topic test-topic \
--bootstrap-server localhost:9092
```

In another terminal, start the producer:

```bash
kafka-console-producer.sh \
--topic test-topic \
--bootstrap-server localhost:9092
```

Enter:

```text
Message 1
Message 2
Message 3
```

The consumer should receive the messages while it is running.

This demonstrates Kafka's basic publish/subscribe workflow.

---

# 21. Delete a Topic

If topic deletion is enabled, a test topic can be removed with:

```bash
kafka-topics.sh \
--delete \
--topic test-topic \
--bootstrap-server localhost:9092
```

Verify:

```bash
kafka-topics.sh \
--list \
--bootstrap-server localhost:9092
```

---

# 22. Stop Kafka

If Kafka is running in the foreground, stop it with:

```text
Ctrl+C
```

Kafka should shut down cleanly.

---

# 23. Starting Kafka in Future Sessions

The basic workflow is:

### Terminal 1

```bash
kafka-start
```

### Terminal 2

Run Kafka commands, for example:

```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

You do **not** need to reformat Kafka storage every time.

The storage formatting step is normally performed only when initializing a new Kafka data directory.

---

# 24. Common Problems

## Problem 1 — `kafka-server-start.sh: command not found`

Check:

```bash
echo $KAFKA_HOME
```

Then:

```bash
which kafka-server-start.sh
```

If necessary:

```bash
export KAFKA_HOME=/mnt/vol_e/bigdata/kafka/kafka_2.13-3.9.1
export PATH=$KAFKA_HOME/bin:$PATH
```

---

## Problem 2 — Java is missing

Check:

```bash
java -version
```

Install Java 17:

```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

Then:

```bash
java -version
```

---

## Problem 3 — Invalid cluster ID

Example:

```text
Invalid cluster.id in:
.../data/meta.properties

Expected <new-id>, but read <old-id>
```

This usually means the storage directory was already formatted using a different cluster ID.

For a **new learning installation with no data to preserve**:

```bash
rm -rf /mnt/vol_e/bigdata/kafka/data/*
```

Generate a new ID:

```bash
$KAFKA_HOME/bin/kafka-storage.sh random-uuid
```

Format again:

```bash
$KAFKA_HOME/bin/kafka-storage.sh format \
-t YOUR_GENERATED_CLUSTER_ID \
-c $KAFKA_HOME/config/kraft/server.properties
```

---

## Problem 4 — Kafka port 9092 is already in use

Check:

```bash
ss -ltnp | grep 9092
```

If an existing Kafka instance is already running, do not start another instance using the same configuration.

Check:

```bash
jps
```

---

## Problem 5 — Topic command cannot connect

For example:

```text
Connection to node -1 could not be established
```

First verify that Kafka is running:

```bash
jps
```

Then:

```bash
ss -ltnp | grep 9092
```

If Kafka is not running:

```bash
kafka-start
```

Then retry:

```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

---

# 25. Kafka Installation Verification

The following commands provide a quick verification of the installation:

```bash
echo $KAFKA_HOME
```

```bash
which kafka-server-start.sh
```

```bash
kafka-server-start.sh --version
```

```bash
jps
```

```bash
ss -ltnp | grep 9092
```

```bash
kafka-topics.sh --list --bootstrap-server localhost:9092
```

A complete producer/consumer test:

### Terminal 1

```bash
kafka-start
```

### Terminal 2

```bash
kafka-topics.sh \
--create \
--topic test-topic \
--bootstrap-server localhost:9092
```

### Terminal 3

```bash
kafka-console-consumer.sh \
--topic test-topic \
--bootstrap-server localhost:9092
```

### Terminal 4

```bash
kafka-console-producer.sh \
--topic test-topic \
--bootstrap-server localhost:9092
```

Enter:

```text
Kafka test message
```

The consumer should receive:

```text
Kafka test message
```

---

# 26. Installation Summary

The final Kafka installation is:

```text
/mnt/vol_e/bigdata/kafka/
└── kafka_2.13-3.9.1/
```

Kafka uses:

```text
KRaft
```

instead of ZooKeeper.

The main configuration is:

```text
$KAFKA_HOME/config/kraft/server.properties
```

Kafka data is stored in:

```text
/mnt/vol_e/bigdata/kafka/data
```

Kafka clients connect through:

```text
localhost:9092
```

The basic architecture is:

```text
              Kafka Cluster
                    │
             ┌──────┴──────┐
             │             │
          Producer      Consumer
             │             ▲
             └──────► Topic ┘
```

For this single-machine learning environment, Kafka runs as a single KRaft node.