# Apache Flume 1.11.0

Apache Flume is a distributed service for efficiently collecting, aggregating, and moving large amounts of log/event data.

In this setup, Flume is configured with a simple **source → channel → sink** pipeline that receives events and writes them to HDFS.

---

## 1. Versions

| Component | Version |
|---|---|
| Apache Flume | 1.11.0 |
| Hadoop | 3.3.6 |
| Java | OpenJDK 8 |
| OS | Ubuntu 24.04 |

Installation directory:

```text
/mnt/vol_e/bigdata/flume/apache-flume-1.11.0-bin
````

---

## 2. Prerequisites

Flume requires Java and needs access to the Hadoop installation when using an HDFS sink.

Verify Java:

```bash
java -version
```

Verify Hadoop:

```bash
hadoop version
```

Verify the Hadoop environment:

```bash
echo $HADOOP_HOME
echo $HADOOP_CONF_DIR
```

Expected:

```text
HADOOP_HOME=/mnt/vol_e/bigdata/hadoop-3.3.6
HADOOP_CONF_DIR=/mnt/vol_e/bigdata/hadoop-3.3.6/etc/hadoop
```

---

## 3. Download Flume

Move to the Big Data installation directory:

```bash
cd /mnt/vol_e/bigdata
```

Create the Flume directory:

```bash
mkdir -p flume
cd flume
```

Download Apache Flume 1.11.0:

```bash
wget https://archive.apache.org/dist/flume/1.11.0/apache-flume-1.11.0-bin.tar.gz
```

Verify the downloaded archive:

```bash
ls -lh apache-flume-1.11.0-bin.tar.gz
```

---

## 4. Extract Flume

Extract the archive:

```bash
tar -xzf apache-flume-1.11.0-bin.tar.gz
```

Verify the installation:

```bash
ls -lah
```

The installation directory should be:

```text
/mnt/vol_e/bigdata/flume/apache-flume-1.11.0-bin
```

The archive can then be removed:

```bash
rm apache-flume-1.11.0-bin.tar.gz
```

---

## 5. Configure Environment Variables

Edit the shell configuration:

```bash
nano ~/.bashrc
```

Add:

```bash
# Apache Flume
export FLUME_HOME=/mnt/vol_e/bigdata/flume/apache-flume-1.11.0-bin
export PATH=$FLUME_HOME/bin:$PATH

# Hadoop
export HADOOP_HOME=/mnt/vol_e/bigdata/hadoop-3.3.6
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $FLUME_HOME
which flume-ng
```

Expected:

```text
/mnt/vol_e/bigdata/flume/apache-flume-1.11.0-bin
/mnt/vol_e/bigdata/flume/apache-flume-1.11.0-bin/bin/flume-ng
```

---

## 6. Verify Flume

Run:

```bash
flume-ng version
```

Expected:

```text
Flume 1.11.0
```

If the command is unavailable, verify:

```bash
ls $FLUME_HOME/bin
```

---

## 7. Flume Architecture

A Flume agent consists of three main components:

```text
Source
   │
   ▼
Channel
   │
   ▼
Sink
```

For this guide:

```text
Netcat Source
      │
      ▼
Memory Channel
      │
      ▼
HDFS Sink
      │
      ▼
HDFS
```

The components have different responsibilities:

### Source

Receives incoming events.

### Channel

Temporarily stores events between the source and sink.

### Sink

Consumes events from the channel and sends them to the destination.

---

## 8. Create the Flume Configuration Directory

Flume configuration files are stored under:

```text
$FLUME_HOME/conf/
```

Verify:

```bash
ls $FLUME_HOME/conf
```

---

## 9. Create an HDFS Agent Configuration

Create:

```text
$FLUME_HOME/conf/hdfs-agent.conf
```

Command:

```bash
nano $FLUME_HOME/conf/hdfs-agent.conf
```

Add:

```properties
# ============================================================
# Flume HDFS Agent
# ============================================================

# ------------------------------------------------------------
# Agent components
# ------------------------------------------------------------

agent.sources = netcat-source
agent.channels = memory-channel
agent.sinks = hdfs-sink


# ------------------------------------------------------------
# Source
# ------------------------------------------------------------

agent.sources.netcat-source.type = netcat
agent.sources.netcat-source.bind = localhost
agent.sources.netcat-source.port = 44444

agent.sources.netcat-source.channels = memory-channel


# ------------------------------------------------------------
# Channel
# ------------------------------------------------------------

agent.channels.memory-channel.type = memory
agent.channels.memory-channel.capacity = 1000
agent.channels.memory-channel.transactionCapacity = 100


# ------------------------------------------------------------
# HDFS Sink
# ------------------------------------------------------------

agent.sinks.hdfs-sink.type = hdfs

agent.sinks.hdfs-sink.hdfs.path = hdfs://localhost:9000/flume/events

agent.sinks.hdfs-sink.hdfs.filePrefix = events-
agent.sinks.hdfs-sink.hdfs.fileSuffix = .log

agent.sinks.hdfs-sink.hdfs.fileType = DataStream

agent.sinks.hdfs-sink.hdfs.writeFormat = Text

agent.sinks.hdfs-sink.hdfs.rollInterval = 30
agent.sinks.hdfs-sink.hdfs.rollSize = 0
agent.sinks.hdfs-sink.hdfs.rollCount = 0

agent.sinks.hdfs-sink.channel = memory-channel
```

---

## 10. Create the HDFS Destination

Before starting Flume, create the destination directory:

```bash
hdfs dfs -mkdir -p /flume/events
```

Verify:

```bash
hdfs dfs -ls /flume
```

Expected:

```text
events
```

---

## 11. Start Flume

Make sure HDFS is running:

```bash
jps
```

You should see Hadoop services such as:

```text
NameNode
DataNode
SecondaryNameNode
```

Start the Flume agent:

```bash
flume-ng agent \
  --conf $FLUME_HOME/conf \
  --conf-file $FLUME_HOME/conf/hdfs-agent.conf \
  --name agent \
  -Dflume.root.logger=INFO,console
```

Flume should start a Netcat source listening on:

```text
localhost:44444
```

Keep this terminal open.

---

## 12. Send Test Data to Flume

Open a second terminal.

Connect to the Netcat source:

```bash
nc localhost 44444
```

You should receive a message indicating that the connection succeeded.

Enter test events:

```text
hello flume
```

```text
hello hdfs
```

```text
this is a Flume test
```

Each line represents an event sent to the Flume source.

Press:

```text
Ctrl+D
```

to close the Netcat connection.

---

## 13. Verify Data in HDFS

Wait for the HDFS sink to roll the file.

Then check:

```bash
hdfs dfs -ls /flume/events
```

You should see files similar to:

```text
events-.<timestamp>.log
```

The exact filename depends on Flume's file rolling configuration.

---

## 14. Read the Flume Data

List the files:

```bash
hdfs dfs -ls /flume/events
```

Then read a file:

```bash
hdfs dfs -cat /flume/events/<filename>
```

For example:

```bash
hdfs dfs -cat /flume/events/events-.<timestamp>.log
```

The output should contain the messages sent through Netcat:

```text
hello flume
hello hdfs
this is a Flume test
```

---

## 15. Important: Directories vs Files

`hdfs dfs -cat` operates on files.

This will not work as expected:

```bash
hdfs dfs -cat /flume/events
```

because `/flume/events` is a directory.

First list its contents:

```bash
hdfs dfs -ls /flume/events
```

Then specify the actual file:

```bash
hdfs dfs -cat /flume/events/<filename>
```

---

## 16. Flume Configuration Explained

The complete pipeline is:

```text
localhost:44444
       │
       ▼
Netcat Source
       │
       ▼
Memory Channel
       │
       ▼
HDFS Sink
       │
       ▼
/flume/events
```

### Source

```properties
agent.sources.netcat-source.type = netcat
```

Uses Flume's Netcat source.

```properties
agent.sources.netcat-source.bind = localhost
agent.sources.netcat-source.port = 44444
```

The source listens on:

```text
localhost:44444
```

### Channel

```properties
agent.channels.memory-channel.type = memory
```

Events are temporarily stored in memory.

This is convenient for learning but is not durable if the Flume process crashes.

### Sink

```properties
agent.sinks.hdfs-sink.type = hdfs
```

The sink writes events into HDFS.

The destination is:

```properties
agent.sinks.hdfs-sink.hdfs.path = hdfs://localhost:9000/flume/events
```

---

## 17. Why File Rolling Is Used

The configuration contains:

```properties
agent.sinks.hdfs-sink.hdfs.rollInterval = 30
agent.sinks.hdfs-sink.hdfs.rollSize = 0
agent.sinks.hdfs-sink.hdfs.rollCount = 0
```

This means the HDFS sink rolls the current file approximately every 30 seconds.

This is useful during testing because the events become visible as files without requiring a large amount of data.

---

## 18. Common Problems

### `flume-ng: command not found`

Check:

```bash
echo $FLUME_HOME
```

and:

```bash
which flume-ng
```

If necessary:

```bash
source ~/.bashrc
```

---

### HDFS sink cannot connect to HDFS

Verify HDFS:

```bash
jps
```

Check:

```bash
hdfs dfs -ls /
```

If HDFS is not running:

```bash
start-dfs.sh
```

Also verify:

```bash
echo $HADOOP_HOME
echo $HADOOP_CONF_DIR
```

---

### `No FileSystem for scheme "hdfs"`

Flume may not have access to the Hadoop filesystem libraries.

Verify:

```bash
echo $HADOOP_HOME
```

and:

```bash
hadoop classpath
```

Set:

```bash
export HADOOP_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)
```

Then restart Flume.

---

### Port 44444 is already in use

Check:

```bash
sudo lsof -i :44444
```

If another Flume process is running, stop it before starting another agent.

---

### Nothing appears in HDFS immediately

Check:

```bash
hdfs dfs -ls /flume/events
```

The sink uses file rolling, so the data may not become visible as a finalized file immediately.

Wait approximately 30 seconds and check again.

---

### `nc` is not installed

Install Netcat:

```bash
sudo apt update
sudo apt install netcat-openbsd
```

Verify:

```bash
nc -h
```

---

## 19. Useful Commands

### Check version

```bash
flume-ng version
```

### Start an agent

```bash
flume-ng agent \
  --conf $FLUME_HOME/conf \
  --conf-file $FLUME_HOME/conf/hdfs-agent.conf \
  --name agent \
  -Dflume.root.logger=INFO,console
```

### Check HDFS

```bash
hdfs dfs -ls /flume/events
```

### Read HDFS output

```bash
hdfs dfs -cat /flume/events/<filename>
```

### Test the Netcat source

```bash
nc localhost 44444
```

### Check Java processes

```bash
jps
```

---

## 20. Optional Alias

The Flume startup command is long, so an alias can make it easier to start.

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
alias flume-hdfs='flume-ng agent --conf $FLUME_HOME/conf --conf-file $FLUME_HOME/conf/hdfs-agent.conf --name agent -Dflume.root.logger=INFO,console'
```

Reload:

```bash
source ~/.bashrc
```

Now the agent can be started with:

```bash
flume-hdfs
```

---

## 21. Stopping Flume

If Flume is running in the foreground, press:

```text
Ctrl+C
```

This stops the Flume agent.

Verify that it is no longer running:

```bash
jps
```

---

## 22. Installation Verification

Verify the installation:

```bash
flume-ng version
```

Verify Hadoop:

```bash
hadoop version
```

Verify the environment:

```bash
echo $FLUME_HOME
echo $HADOOP_HOME
```

Verify HDFS:

```bash
hdfs dfs -ls /
```

Start the Flume agent:

```bash
flume-hdfs
```

From another terminal:

```bash
nc localhost 44444
```

Send:

```text
Flume test message
```

Then verify:

```bash
hdfs dfs -ls /flume/events
```

Finally:

```bash
hdfs dfs -cat /flume/events/<filename>
```

If the test message appears, the Flume → HDFS pipeline is working.

---

## 23. Final Architecture

The completed setup is:

```text
                   Apache Flume
                        │
                        │
                ┌───────▼────────┐
                │  Netcat Source │
                │  localhost:44444
                └───────┬────────┘
                        │
                        ▼
                ┌───────────────┐
                │ Memory Channel│
                └───────┬───────┘
                        │
                        ▼
                ┌───────────────┐
                │   HDFS Sink   │
                └───────┬───────┘
                        │
                        ▼
              ┌───────────────────┐
              │ Hadoop HDFS 3.3.6 │
              │ /flume/events     │
              └───────────────────┘
```

This demonstrates the fundamental Flume architecture:

```text
Source → Channel → Sink
```

and provides a simple example of moving event data into HDFS.