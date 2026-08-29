# Prerequisites

This guide sets up the common Ubuntu environment required for the Big Data tools covered in this repository.

The instructions assume:

- Ubuntu 24.04 LTS
- x86_64 architecture
- A user with `sudo` privileges
- Internet access
- `/mnt/vol_e/bigdata` as the installation directory

> **Note:** If your system uses a different partition or installation directory, replace `/mnt/vol_e/bigdata` throughout the guide.

---

## 1. Update Ubuntu

Update the package lists:

```bash
sudo apt update
````

Upgrade installed packages:

```bash
sudo apt upgrade -y
```

---

## 2. Install Basic Utilities

Install the utilities used throughout the guide:

```bash
sudo apt install -y \
    wget \
    curl \
    git \
    unzip \
    tar \
    gzip \
    bzip2 \
    net-tools \
    openssh-client \
    openssh-server \
    rsync \
    build-essential \
    python3 \
    python3-pip \
    python3-venv
```

Verify the main utilities:

```bash
wget --version
curl --version
git --version
python3 --version
```

---

## 3. Configure SSH

Hadoop uses SSH to start and stop its distributed services.

Install the SSH server:

```bash
sudo apt install -y openssh-server
```

Start the SSH service:

```bash
sudo systemctl start ssh
```

Enable SSH at system startup:

```bash
sudo systemctl enable ssh
```

Check the service:

```bash
sudo systemctl status ssh
```

---

## 4. Configure Passwordless Local SSH

Generate an SSH key if one does not already exist:

```bash
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
```

> If `~/.ssh/id_rsa` already exists, do not overwrite it. You can use the existing key.

Add the public key to the authorized keys:

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

Set the required permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
```

Test the connection:

```bash
ssh localhost
```

The first connection may ask whether you trust the host:

```text
Are you sure you want to continue connecting (yes/no/[fingerprint])?
```

Enter:

```text
yes
```

Then exit the SSH session:

```bash
exit
```

Test again:

```bash
ssh localhost
```

The second connection should not require the user's password.

---

## 5. Check the Operating System

Check the Ubuntu version:

```bash
lsb_release -a
```

Alternatively:

```bash
cat /etc/os-release
```

Check the CPU architecture:

```bash
uname -m
```

For most modern systems, the expected output is:

```text
x86_64
```

---

## 6. Install Java

Several tools in this repository have different Java requirements.

Install OpenJDK 8:

```bash
sudo apt install -y openjdk-8-jdk
```

Install OpenJDK 17:

```bash
sudo apt install -y openjdk-17-jdk
```

Check the installed Java version:

```bash
java -version
```

List available Java installations:

```bash
sudo update-alternatives --config java
```

The installations should normally be located under:

```text
/usr/lib/jvm/
```

Verify Java 8:

```bash
ls /usr/lib/jvm/java-8-openjdk-amd64
```

Verify Java 17:

```bash
ls /usr/lib/jvm/java-17-openjdk-amd64
```

---

## 7. Java Version Requirements

Do not assume that every tool in the stack uses the same Java version.

The environment used by this guide is:

| Tool                  | Java                                 |
| --------------------- | ------------------------------------ |
| Hadoop                | Java 8                               |
| Hive                  | Java 8                               |
| HBase                 | Java 8                               |
| Spark                 | Java 8/17 depending on Spark version |
| Flink                 | Java 17                              |
| Flume                 | Java 8                               |
| Sqoop                 | Java 8                               |
| Kafka 3.9.1           | Java 17                              |
| Elasticsearch 8.17.10 | Bundled JDK                          |
| Logstash 8.17.10      | Bundled JDK                          |
| Kibana                | No Java requirement                  |

For tools requiring Java 8:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

For tools requiring Java 17:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

Verify:

```bash
echo $JAVA_HOME
java -version
```

### Elasticsearch

Elasticsearch 8.x normally uses its bundled JDK instead of the system `JAVA_HOME`.

For example, Elasticsearch may display:

```text
warning: ignoring JAVA_HOME=...; using bundled JDK
```

This is expected behavior.

---

## 8. Create the Big Data Installation Directory

This guide installs the tools under:

```text
/mnt/vol_e/bigdata
```

Create the directory:

```bash
sudo mkdir -p /mnt/vol_e/bigdata
```

Give the current user ownership:

```bash
sudo chown -R "$USER:$USER" /mnt/vol_e/bigdata
```

Verify:

```bash
ls -ld /mnt/vol_e/bigdata
```

Test that the current user can write to the directory:

```bash
touch /mnt/vol_e/bigdata/test
```

Remove the test file:

```bash
rm /mnt/vol_e/bigdata/test
```

---

## 9. Create Tool Directories

Move into the Big Data directory:

```bash
cd /mnt/vol_e/bigdata
```

Create directories for the tools:

```bash
mkdir -p \
    hadoop \
    hive \
    spark \
    flink \
    flume \
    hbase \
    sqoop \
    elasticsearch \
    logstash \
    kafka \
    hdfs
```

Create the HDFS storage directories:

```bash
mkdir -p hdfs/namenode
mkdir -p hdfs/datanode
```

Check the directory structure:

```bash
find /mnt/vol_e/bigdata -maxdepth 2 -type d | sort
```

---

## 10. Configure Environment Variables

Create a shell environment file:

```bash
nano ~/.bigdata_env
```

Add:

```bash
# Big Data installation root
export BIGDATA_HOME=/mnt/vol_e/bigdata

# Hadoop
export HADOOP_HOME=$BIGDATA_HOME/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME

# YARN
export YARN_CONF_DIR=$HADOOP_CONF_DIR

# Hive
export HIVE_HOME=$BIGDATA_HOME/hive

# Spark
export SPARK_HOME=$BIGDATA_HOME/spark

# Flink
export FLINK_HOME=$BIGDATA_HOME/flink

# Flume
export FLUME_HOME=$BIGDATA_HOME/flume

# HBase
export HBASE_HOME=$BIGDATA_HOME/hbase

# Sqoop
export SQOOP_HOME=$BIGDATA_HOME/sqoop

# Elasticsearch
export ELASTICSEARCH_HOME=$BIGDATA_HOME/elasticsearch

# Logstash
export LOGSTASH_HOME=$BIGDATA_HOME/logstash

# Kafka
export KAFKA_HOME=$BIGDATA_HOME/kafka

# Hadoop and Big Data executables
export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
export PATH=$HIVE_HOME/bin:$PATH
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
export PATH=$FLINK_HOME/bin:$PATH
export PATH=$FLUME_HOME/bin:$PATH
export PATH=$HBASE_HOME/bin:$HBASE_HOME/sbin:$PATH
export PATH=$SQOOP_HOME/bin:$PATH
export PATH=$ELASTICSEARCH_HOME/bin:$PATH
export PATH=$LOGSTASH_HOME/bin:$PATH
export PATH=$KAFKA_HOME/bin:$PATH
```

Save the file.

Load the variables:

```bash
source ~/.bigdata_env
```

Verify:

```bash
echo $BIGDATA_HOME
echo $HADOOP_HOME
echo $HIVE_HOME
echo $SPARK_HOME
echo $FLINK_HOME
echo $FLUME_HOME
echo $HBASE_HOME
echo $SQOOP_HOME
echo $ELASTICSEARCH_HOME
echo $LOGSTASH_HOME
echo $KAFKA_HOME
```

---

## 11. Load the Environment Automatically

To load the environment variables whenever a new terminal is opened:

```bash
echo 'source ~/.bigdata_env' >> ~/.bashrc
```

Reload the shell configuration:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $BIGDATA_HOME
```

Expected:

```text
/mnt/vol_e/bigdata
```

---

## 12. Check Disk Space

Big Data software can consume significant disk space.

Check available storage:

```bash
df -h
```

Pay particular attention to:

```text
/
```

and:

```text
/mnt/vol_e
```

Check the specific installation partition:

```bash
df -h /mnt/vol_e
```

The partition should have enough space for:

* Hadoop data
* Hive warehouse data
* Spark temporary files
* HBase data
* Kafka logs
* Elasticsearch indices
* downloaded installation archives

---

## 13. Check Memory

Check available RAM:

```bash
free -h
```

Check CPU information:

```bash
lscpu
```

When running multiple services simultaneously, available RAM is especially important.

For a local learning environment, it is often useful to stop services that are not currently being studied.

---

## 14. Verify the Prerequisites

Run the following checks:

```bash
echo "=== Operating System ==="
lsb_release -ds

echo
echo "=== Architecture ==="
uname -m

echo
echo "=== Java ==="
java -version

echo
echo "=== JAVA_HOME ==="
echo "$JAVA_HOME"

echo
echo "=== Python ==="
python3 --version

echo
echo "=== Git ==="
git --version

echo
echo "=== SSH ==="
ssh -V

echo
echo "=== Big Data Directory ==="
echo "$BIGDATA_HOME"

echo
echo "=== Disk Space ==="
df -h "$BIGDATA_HOME"

echo
echo "=== Memory ==="
free -h
```

---

# Common Problems

## Problem 1: `JAVA_HOME is not set`

If a Hadoop or another Java-based tool reports:

```text
JAVA_HOME is not set
```

set the correct Java version:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

or:

```bash
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

Then verify:

```bash
echo $JAVA_HOME
java -version
```

---

## Problem 2: The wrong Java version is active

Check:

```bash
java -version
echo $JAVA_HOME
```

List installed Java versions:

```bash
sudo update-alternatives --config java
```

Select the required version.

Remember that changing the system Java version does not automatically change `JAVA_HOME`.

---

## Problem 3: `Permission denied` under `/mnt/vol_e/bigdata`

Check ownership:

```bash
ls -ld /mnt/vol_e/bigdata
```

If necessary:

```bash
sudo chown -R "$USER:$USER" /mnt/vol_e/bigdata
```

Avoid running the Big Data services as `root` unless specifically required.

---

## Problem 4: SSH asks for the password

Check that the public key exists:

```bash
ls -l ~/.ssh/id_rsa.pub
```

Add it to the authorized keys:

```bash
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
```

Fix permissions:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

Test:

```bash
ssh localhost
```

---

## Problem 5: SSH connection refused

Check the SSH service:

```bash
sudo systemctl status ssh
```

Start it if necessary:

```bash
sudo systemctl start ssh
```

---

## Problem 6: The installation partition is full

Check:

```bash
df -h
```

Find large directories:

```bash
du -h --max-depth=1 /mnt/vol_e/bigdata | sort -h
```

Do not delete Hadoop, Kafka, Elasticsearch, or HBase data directories unless you understand what data they contain.

---

## Problem 7: Environment variables disappear after opening a new terminal

Check:

```bash
grep bigdata_env ~/.bashrc
```

If the environment file is not sourced, add:

```bash
echo 'source ~/.bigdata_env' >> ~/.bashrc
```

Then:

```bash
source ~/.bashrc
```

---

# Installation Directory Structure

After completing this guide, the main directory should look similar to:

```text
/mnt/vol_e/bigdata/
├── hadoop/
├── hive/
├── spark/
├── flink/
├── flume/
├── hbase/
├── sqoop/
├── elasticsearch/
├── logstash/
├── kafka/
└── hdfs/
    ├── namenode/
    └── datanode/
```

The individual tool directories will contain the extracted software after completing their respective installation guides.

---

