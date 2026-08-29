# Apache Hadoop 3.3.6

This guide installs and configures Apache Hadoop 3.3.6 on Ubuntu 24.04 in **pseudo-distributed mode**.

Pseudo-distributed mode runs Hadoop's daemons as separate processes on a single Ubuntu machine:

```text
                    Ubuntu Machine
                         │
        ┌────────────────┼────────────────┐
        │                │                │
        ▼                ▼                ▼
    NameNode          DataNode       SecondaryNameNode
        │
        │
        └────────────── HDFS
                         │
                         ▼
                  ResourceManager
                         │
                         ▼
                    NodeManager
                         │
                         ▼
                       YARN
````

This configuration is intended for:

* Learning Hadoop
* Hadoop labs
* Testing HDFS
* Testing YARN
* Running MapReduce jobs
* Providing HDFS/YARN to tools such as Hive, Spark, Flink, HBase, Flume, and Sqoop

It is **not** intended to be a production Hadoop cluster.

---

# 1. Prerequisites

Complete the general prerequisites guide first:

```text
docs/00-prerequisites.md
```

The setup assumes:

| Component              | Version              |
| ---------------------- | -------------------- |
| Ubuntu                 | 24.04 LTS            |
| Java                   | OpenJDK 8            |
| Hadoop                 | 3.3.6                |
| Installation directory | `/mnt/vol_e/bigdata` |

Verify Java:

```bash
java -version
```

Verify the installation directory:

```bash
echo $BIGDATA_HOME
```

Expected:

```text
/mnt/vol_e/bigdata
```

---

# 2. Download Hadoop

Move to the Big Data installation directory:

```bash
cd /mnt/vol_e/bigdata
```

Download Hadoop 3.3.6:

```bash
wget https://archive.apache.org/dist/hadoop/common/hadoop-3.3.6/hadoop-3.3.6.tar.gz
```

Verify that the archive exists:

```bash
ls -lh hadoop-3.3.6.tar.gz
```

---

# 3. Extract Hadoop

Extract the archive:

```bash
tar -xzf hadoop-3.3.6.tar.gz
```

Verify:

```bash
ls -ld hadoop-3.3.6
```

The installation should now exist at:

```text
/mnt/vol_e/bigdata/hadoop-3.3.6
```

---

# 4. Create the Hadoop Installation Path

If you want the environment variable to point to:

```text
/mnt/vol_e/bigdata/hadoop
```

create a symbolic link:

```bash
ln -s hadoop-3.3.6 hadoop
```

If `hadoop` already exists, check it before creating the link:

```bash
ls -ld /mnt/vol_e/bigdata/hadoop
```

The resulting structure should look like:

```text
/mnt/vol_e/bigdata/
├── hadoop -> hadoop-3.3.6
└── hadoop-3.3.6/
```

---

# 5. Configure Environment Variables

The common environment file created in `docs/00-prerequisites.md` should contain:

```bash
export BIGDATA_HOME=/mnt/vol_e/bigdata

export HADOOP_HOME=$BIGDATA_HOME/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME

export YARN_CONF_DIR=$HADOOP_CONF_DIR

export PATH=$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$PATH
```

Load the environment:

```bash
source ~/.bigdata_env
```

Verify:

```bash
echo $HADOOP_HOME
```

Expected:

```text
/mnt/vol_e/bigdata/hadoop
```

Verify Hadoop:

```bash
hadoop version
```

Expected:

```text
Hadoop 3.3.6
```

---

# 6. Configure Java

Hadoop 3.3.6 is configured in this environment to use Java 8.

Check the Java installation:

```bash
ls /usr/lib/jvm/java-8-openjdk-amd64
```

Set `JAVA_HOME`:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

Verify:

```bash
echo $JAVA_HOME
java -version
```

---

# 7. Configure `hadoop-env.sh`

Open:

```bash
nano $HADOOP_HOME/etc/hadoop/hadoop-env.sh
```

Find the `JAVA_HOME` setting and set it to:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

Verify:

```bash
grep JAVA_HOME $HADOOP_HOME/etc/hadoop/hadoop-env.sh
```

You should see:

```text
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

---

# 8. Configure `core-site.xml`

Open:

```bash
nano $HADOOP_HOME/etc/hadoop/core-site.xml
```

Replace the contents with:

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>

</configuration>
```

The important setting is:

```text
fs.defaultFS = hdfs://localhost:9000
```

This tells Hadoop where the HDFS NameNode is located.

---

# 9. Configure `hdfs-site.xml`

Open:

```bash
nano $HADOOP_HOME/etc/hadoop/hdfs-site.xml
```

Use:

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>

    <property>
        <name>dfs.namenode.name.dir</name>
        <value>file:///mnt/vol_e/bigdata/hdfs/namenode</value>
    </property>

    <property>
        <name>dfs.datanode.data.dir</name>
        <value>file:///mnt/vol_e/bigdata/hdfs/datanode</value>
    </property>

</configuration>
```

### Why replication is `1`

This is a single-machine learning environment.

There is only one DataNode, so:

```text
dfs.replication = 1
```

is appropriate.

A production cluster would normally use a higher replication factor.

---

# 10. Create HDFS Storage Directories

Create the NameNode directory:

```bash
mkdir -p /mnt/vol_e/bigdata/hdfs/namenode
```

Create the DataNode directory:

```bash
mkdir -p /mnt/vol_e/bigdata/hdfs/datanode
```

Verify:

```bash
ls -ld /mnt/vol_e/bigdata/hdfs/*
```

Make sure the current user owns the directories:

```bash
sudo chown -R "$USER:$USER" /mnt/vol_e/bigdata/hdfs
```

---

# 11. Configure MapReduce

Copy the default MapReduce configuration:

```bash
cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template \
   $HADOOP_HOME/etc/hadoop/mapred-site.xml
```

Open it:

```bash
nano $HADOOP_HOME/etc/hadoop/mapred-site.xml
```

Use:

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>

</configuration>
```

This tells MapReduce to use YARN as its execution framework.

---

# 12. Configure YARN

Open:

```bash
nano $HADOOP_HOME/etc/hadoop/yarn-site.xml
```

Use:

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>

    <property>
        <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
        <value>org.apache.hadoop.mapred.ShuffleHandler</value>
    </property>

</configuration>
```

The shuffle service is required by MapReduce jobs running on YARN.

---

# 13. Configure Local SSH

Hadoop's startup scripts use SSH to start its daemons.

Verify SSH:

```bash
ssh localhost
```

If it works without asking for a password, continue.

If not, follow the SSH configuration in:

```text
docs/00-prerequisites.md
```

Test again:

```bash
ssh localhost
```

Exit:

```bash
exit
```

---

# 14. Format the NameNode

> **Warning:** Formatting the NameNode initializes a new HDFS filesystem. Do not run this on an existing HDFS installation containing data you want to keep.

Format:

```bash
hdfs namenode -format
```

A successful format should report that the NameNode storage directory was successfully formatted.

---

# 15. Start HDFS

Start HDFS:

```bash
start-dfs.sh
```

Check the running Hadoop processes:

```bash
jps
```

Expected:

```text
NameNode
DataNode
SecondaryNameNode
```

The exact process IDs will be different on every system.

---

# 16. Verify HDFS

Check the root directory:

```bash
hdfs dfs -ls /
```

Create a test directory:

```bash
hdfs dfs -mkdir /test
```

Verify:

```bash
hdfs dfs -ls /
```

You should see:

```text
/test
```

---

# 17. Test Uploading a File

Create a local file:

```bash
echo "Hello Hadoop" > ~/hadoop-test.txt
```

Upload it to HDFS:

```bash
hdfs dfs -put ~/hadoop-test.txt /test/
```

List the directory:

```bash
hdfs dfs -ls /test
```

Read the file:

```bash
hdfs dfs -cat /test/hadoop-test.txt
```

Expected:

```text
Hello Hadoop
```

This confirms that HDFS can:

1. Create directories
2. Store files
3. Retrieve files

---

# 18. Check HDFS Health

Run:

```bash
hdfs dfsadmin -report
```

The report should show one live DataNode.

For example:

```text
Live datanodes (1):
```

This is another useful confirmation that the DataNode is connected to the NameNode.

---

# 19. Start YARN

Once HDFS is working, start YARN:

```bash
start-yarn.sh
```

Check:

```bash
jps
```

Expected processes:

```text
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
```

---

# 20. Check YARN

List running applications:

```bash
yarn application -list
```

At this point there may be no running applications.

Check YARN nodes:

```bash
yarn node -list
```

Expected output should show one active NodeManager.

---

# 21. Run a MapReduce Example

Hadoop provides example JAR files.

Locate the examples:

```bash
find $HADOOP_HOME/share/hadoop/mapreduce -name "hadoop-mapreduce-examples-*.jar"
```

Create an input directory:

```bash
hdfs dfs -mkdir -p /wordcount/input
```

Create a local input file:

```bash
cat > ~/wordcount.txt <<'EOF'
hello hadoop
hello yarn
hello hadoop
EOF
```

Upload it:

```bash
hdfs dfs -put ~/wordcount.txt /wordcount/input/
```

Run WordCount:

```bash
hadoop jar \
$HADOOP_HOME/share/hadoop/mapreduce/hadoop-mapreduce-examples-3.3.6.jar \
wordcount \
/wordcount/input \
/wordcount/output
```

Check the output:

```bash
hdfs dfs -ls /wordcount/output
```

Read the result:

```bash
hdfs dfs -cat /wordcount/output/part-r-00000
```

Expected output should contain something similar to:

```text
hadoop  2
hello   3
yarn    1
```

The exact formatting may differ.

---

# 22. Access Hadoop Web Interfaces

Hadoop provides web interfaces for monitoring the services.

## NameNode

Open:

```text
http://localhost:9870
```

The NameNode UI provides information about:

* HDFS capacity
* DataNodes
* Filesystem information
* HDFS health

## ResourceManager

Open:

```text
http://localhost:8088
```

The ResourceManager UI provides information about:

* YARN applications
* Cluster resources
* NodeManagers
* Running jobs

---

# 23. Useful HDFS Commands

List HDFS root:

```bash
hdfs dfs -ls /
```

Create a directory:

```bash
hdfs dfs -mkdir /directory
```

Create nested directories:

```bash
hdfs dfs -mkdir -p /directory/subdirectory
```

Upload a file:

```bash
hdfs dfs -put local-file.txt /directory/
```

Copy a file into HDFS:

```bash
hdfs dfs -copyFromLocal local-file.txt /directory/
```

Download a file:

```bash
hdfs dfs -get /directory/file.txt .
```

Read a file:

```bash
hdfs dfs -cat /directory/file.txt
```

Remove a file:

```bash
hdfs dfs -rm /directory/file.txt
```

Remove a directory:

```bash
hdfs dfs -rm -r /directory
```

Check disk usage:

```bash
hdfs dfs -du -h /
```

Check filesystem status:

```bash
hdfs dfsadmin -report
```

---

# 24. Stop Hadoop Services

Stop YARN first:

```bash
stop-yarn.sh
```

Then stop HDFS:

```bash
stop-dfs.sh
```

Verify:

```bash
jps
```

The Hadoop daemons should no longer appear.

---

# 25. Start Everything Again

After the initial configuration, you do not need to format the NameNode again.

Start HDFS:

```bash
start-dfs.sh
```

Start YARN:

```bash
start-yarn.sh
```

Verify:

```bash
jps
```

Expected:

```text
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
```

> **Do not run `hdfs namenode -format` every time Hadoop is started.**
>
> Formatting is an initialization operation, not a startup command.

---

# 26. Useful Convenience Aliases

Starting Hadoop requires two commands:

```bash
start-dfs.sh
start-yarn.sh
```

Create a simple alias:

```bash
echo "alias hadoop-start='start-dfs.sh && start-yarn.sh'" >> ~/.bashrc
```

Create a shutdown alias:

```bash
echo "alias hadoop-stop='stop-yarn.sh && stop-dfs.sh'" >> ~/.bashrc
```

Reload:

```bash
source ~/.bashrc
```

Now Hadoop can be started with:

```bash
hadoop-start
```

and stopped with:

```bash
hadoop-stop
```

Check the services:

```bash
jps
```

---

# 27. Troubleshooting

## Problem: `JAVA_HOME is not set`

Error:

```text
JAVA_HOME is not set and could not be found.
```

Check:

```bash
echo $JAVA_HOME
```

Set Java 8:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

Also verify `$HADOOP_HOME/etc/hadoop/hadoop-env.sh` contains:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
```

---

## Problem: Hadoop commands are not found

Example:

```text
hadoop: command not found
```

Check:

```bash
echo $HADOOP_HOME
```

Check:

```bash
which hadoop
```

Reload the environment:

```bash
source ~/.bigdata_env
```

Verify:

```bash
which hadoop
hadoop version
```

---

## Problem: `start-dfs.sh` cannot SSH to localhost

Test:

```bash
ssh localhost
```

If a password is requested every time, configure passwordless local SSH using the prerequisites guide.

Check:

```bash
ls -la ~/.ssh
```

---

## Problem: NameNode does not start

Check:

```bash
jps
```

Then inspect the Hadoop logs:

```bash
ls -lh $HADOOP_HOME/logs
```

Look for NameNode logs:

```bash
ls $HADOOP_HOME/logs/*namenode*
```

Read the latest relevant log:

```bash
tail -n 100 $HADOOP_HOME/logs/*namenode*.log
```

Common causes include:

* Incorrect `JAVA_HOME`
* Incorrect HDFS directory permissions
* Invalid XML configuration
* An already running NameNode
* A previously formatted filesystem using a different configuration

---

## Problem: DataNode does not start

Check:

```bash
jps
```

Inspect DataNode logs:

```bash
tail -n 100 $HADOOP_HOME/logs/*datanode*.log
```

Check the DataNode directory:

```bash
ls -ld /mnt/vol_e/bigdata/hdfs/datanode
```

Fix ownership if necessary:

```bash
sudo chown -R "$USER:$USER" /mnt/vol_e/bigdata/hdfs
```

---

## Problem: HDFS reports `SafeMode`

Check:

```bash
hdfs dfsadmin -safemode get
```

If the filesystem is ready but remains in safe mode:

```bash
hdfs dfsadmin -safemode leave
```

Do not blindly disable safe mode in a production environment. Safe mode exists to protect HDFS while it verifies filesystem state.

---

## Problem: YARN does not start

Check:

```bash
jps
```

You should see:

```text
ResourceManager
NodeManager
```

If either is missing, inspect:

```bash
ls -lh $HADOOP_HOME/logs
```

ResourceManager log:

```bash
tail -n 100 $HADOOP_HOME/logs/*resourcemanager*.log
```

NodeManager log:

```bash
tail -n 100 $HADOOP_HOME/logs/*nodemanager*.log
```

---

## Problem: YARN complains about Java module access

Some Hadoop/YARN components can encounter Java module-access errors when used with newer Java versions.

For example:

```text
InaccessibleObjectException
```

The first thing to check is:

```bash
java -version
echo $JAVA_HOME
```

For this environment, Hadoop is configured to use:

```text
/usr/lib/jvm/java-8-openjdk-amd64
```

Make sure Hadoop is actually using Java 8.

---

## Problem: Configuration changes do not seem to take effect

Check which configuration directory Hadoop is using:

```bash
echo $HADOOP_CONF_DIR
```

Expected:

```text
/mnt/vol_e/bigdata/hadoop/etc/hadoop
```

Check the actual configuration:

```bash
cat $HADOOP_CONF_DIR/core-site.xml
cat $HADOOP_CONF_DIR/hdfs-site.xml
cat $HADOOP_CONF_DIR/mapred-site.xml
cat $HADOOP_CONF_DIR/yarn-site.xml
```

---

## Problem: `hdfs dfs -cat` says the path is a directory

For example:

```bash
hdfs dfs -cat /test
```

If `/test` is a directory, `cat` cannot read it.

List its contents:

```bash
hdfs dfs -ls /test
```

Then specify the file:

```bash
hdfs dfs -cat /test/hadoop-test.txt
```

---

## Problem: Port already in use

Check the relevant ports:

```bash
netstat -tlnp | grep -E '9000|9870|8088|9864|8042'
```

Or:

```bash
ss -tlnp | grep -E '9000|9870|8088|9864|8042'
```

If an old Hadoop daemon is still running, check:

```bash
jps
```

Stop the services:

```bash
stop-yarn.sh
stop-dfs.sh
```

Then verify:

```bash
jps
```

---

# 28. Clean Reset of a Learning Installation

If this is a disposable learning installation and HDFS needs to be completely reset, stop Hadoop first:

```bash
stop-yarn.sh
stop-dfs.sh
```

Delete the HDFS metadata/data:

```bash
rm -rf /mnt/vol_e/bigdata/hdfs/namenode/*
rm -rf /mnt/vol_e/bigdata/hdfs/datanode/*
```

Format again:

```bash
hdfs namenode -format
```

Start HDFS:

```bash
start-dfs.sh
```

Start YARN:

```bash
start-yarn.sh
```

Verify:

```bash
jps
```

> **Warning:** This destroys the HDFS filesystem stored in these directories. Only use this procedure for a learning environment where the data can be recreated.

---

# 29. Final Verification Checklist

Run:

```bash
hadoop version
```

Then:

```bash
jps
```

Expected:

```text
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
```

Check HDFS:

```bash
hdfs dfs -ls /
```

Check DataNode health:

```bash
hdfs dfsadmin -report
```

Check YARN:

```bash
yarn node -list
```

Test HDFS storage:

```bash
echo "Hadoop works" > ~/hadoop-test.txt
hdfs dfs -mkdir -p /test
hdfs dfs -put -f ~/hadoop-test.txt /test/
hdfs dfs -cat /test/hadoop-test.txt
```

Expected:

```text
Hadoop works
```

---

# 30. Expected Final Directory Structure

The important parts of the installation should look like:

```text
/mnt/vol_e/bigdata/
│
├── hadoop -> hadoop-3.3.6
│
├── hadoop-3.3.6/
│   ├── bin/
│   ├── etc/
│   │   └── hadoop/
│   │       ├── core-site.xml
│   │       ├── hdfs-site.xml
│   │       ├── mapred-site.xml
│   │       ├── yarn-site.xml
│   │       └── hadoop-env.sh
│   ├── lib/
│   ├── sbin/
│   └── share/
│
└── hdfs/
    ├── namenode/
    └── datanode/
```

---

# 31. Hadoop Commands Quick Reference

### Start

```bash
start-dfs.sh
start-yarn.sh
```

### Stop

```bash
stop-yarn.sh
stop-dfs.sh
```

### Check processes

```bash
jps
```

### Check HDFS

```bash
hdfs dfs -ls /
```

### Check DataNodes

```bash
hdfs dfsadmin -report
```

### Check YARN nodes

```bash
yarn node -list
```

### HDFS Web UI

```text
http://localhost:9870
```

### YARN Web UI

```text
http://localhost:8088
```

---

# 32. What This Installation Provides

After completing this guide, the machine provides a local Hadoop environment consisting of:

```text
HDFS
│
├── NameNode
├── DataNode
└── SecondaryNameNode

YARN
│
├── ResourceManager
└── NodeManager
```

Applications such as:

```text
MapReduce
Hive
Spark
Flink
Flume
HBase
Sqoop
```

can subsequently use this Hadoop installation.

For example, Spark can later submit applications to YARN:

```bash
spark-submit --master yarn application.py
```

and applications such as Flume can write data directly to HDFS.