# Apache HBase 2.5.12

Apache HBase is a distributed, column-oriented NoSQL database designed to run on top of Hadoop HDFS.

In this guide, HBase is configured in distributed mode using the existing Hadoop 3.3.6 installation and HDFS.

---

## 1. Versions

| Component | Version |
|---|---|
| Apache HBase | 2.5.12 |
| Hadoop | 3.3.6 |
| Java | OpenJDK 8 |
| OS | Ubuntu 24.04 |

Installation directory:

```text
/mnt/vol_e/bigdata/hbase/hbase-2.5.12-hadoop3
````

---

## 2. Prerequisites

HBase depends on Hadoop and Java.

Verify Java:

```bash
java -version
```

Verify Hadoop:

```bash
hadoop version
```

Verify the Hadoop installation:

```bash
echo $HADOOP_HOME
```

Expected:

```text
/mnt/vol_e/bigdata/hadoop-3.3.6
```

Verify HDFS is running:

```bash
jps
```

Expected Hadoop processes include:

```text
NameNode
DataNode
SecondaryNameNode
```

Test HDFS:

```bash
hdfs dfs -ls /
```

If HDFS is not running:

```bash
start-dfs.sh
```

---

## 3. Download HBase

Move to the Big Data installation directory:

```bash
cd /mnt/vol_e/bigdata
```

Create the HBase directory:

```bash
mkdir -p hbase
cd hbase
```

Download HBase 2.5.12 with Hadoop 3 support:

```bash
wget https://archive.apache.org/dist/hbase/2.5.12/hbase-2.5.12-hadoop3-bin.tar.gz
```

Verify:

```bash
ls -lh hbase-2.5.12-hadoop3-bin.tar.gz
```

---

## 4. Extract HBase

Extract the archive:

```bash
tar -xzf hbase-2.5.12-hadoop3-bin.tar.gz
```

Verify:

```bash
ls -lah
```

The installation directory should be:

```text
/mnt/vol_e/bigdata/hbase/hbase-2.5.12-hadoop3
```

Remove the archive after extraction:

```bash
rm hbase-2.5.12-hadoop3-bin.tar.gz
```

---

## 5. Configure Environment Variables

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
# Apache HBase
export HBASE_HOME=/mnt/vol_e/bigdata/hbase/hbase-2.5.12-hadoop3
export PATH=$HBASE_HOME/bin:$PATH

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
echo $HBASE_HOME
which hbase
```

Expected:

```text
/mnt/vol_e/bigdata/hbase/hbase-2.5.12-hadoop3
/mnt/vol_e/bigdata/hbase/bin/hbase
```

The exact second path should correspond to the configured `$HBASE_HOME/bin/hbase`.

---

## 6. Configure Java

HBase should use the Java version compatible with the selected Hadoop/HBase setup.

Edit:

```bash
nano $HBASE_HOME/conf/hbase-env.sh
```

Add or update:

```bash
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export HBASE_MANAGES_ZK=true
export HADOOP_HOME=/mnt/vol_e/bigdata/hadoop-3.3.6
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
```

Check:

```bash
echo $JAVA_HOME
```

Expected:

```text
/usr/lib/jvm/java-8-openjdk-amd64
```

---

## 7. Configure HBase

HBase configuration is stored in:

```text
$HBASE_HOME/conf/
```

The main configuration file is:

```text
$HBASE_HOME/conf/hbase-site.xml
```

Open it:

```bash
nano $HBASE_HOME/conf/hbase-site.xml
```

For the distributed HDFS-backed configuration, use:

```xml
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

    <property>
        <name>hbase.rootdir</name>
        <value>hdfs://localhost:9000/hbase</value>
    </property>

    <property>
        <name>hbase.cluster.distributed</name>
        <value>true</value>
    </property>

    <property>
        <name>hbase.unsafe.stream.capability.enforce</name>
        <value>false</value>
    </property>

</configuration>
```

### Configuration explanation

`hbase.rootdir` specifies where HBase stores its data.

```text
hdfs://localhost:9000/hbase
```

means that HBase uses the existing Hadoop HDFS cluster.

`hbase.cluster.distributed` enables distributed mode.

```xml
<value>true</value>
```

Even though this is a single-machine learning environment, HBase can still run its distributed components on the same machine.

---

## 8. Configure HBase to Use Hadoop Configuration

HBase needs access to Hadoop's configuration files.

Verify:

```bash
ls $HADOOP_CONF_DIR
```

You should see files such as:

```text
core-site.xml
hdfs-site.xml
mapred-site.xml
yarn-site.xml
```

The Hadoop configuration directory is:

```text
/mnt/vol_e/bigdata/hadoop-3.3.6/etc/hadoop
```

Because `HADOOP_CONF_DIR` is configured in `hbase-env.sh`, HBase can use the existing Hadoop configuration.

---

## 9. Start HBase

Make sure HDFS is running:

```bash
jps
```

Then start HBase:

```bash
start-hbase.sh
```

Check the Java processes:

```bash
jps
```

A successful distributed HBase installation should show processes such as:

```text
HMaster
HRegionServer
HQuorumPeer
```

The exact list can vary depending on the HBase configuration.

---

## 10. Open HBase Shell

Start the HBase shell:

```bash
hbase shell
```

You should see:

```text
HBase Shell
```

The shell provides commands for creating tables, inserting data, scanning rows, and deleting tables.

---

## 11. Check HBase Status

Inside HBase Shell:

```text
status
```

For a simpler status output:

```text
status 'simple'
```

A working installation should report an active master and at least one live server.

Example:

```text
1 active master
1 live server
0 dead servers
```

Exit the shell:

```text
exit
```

---

## 12. Create a Test Table

Open HBase Shell:

```bash
hbase shell
```

Create a table called `students` with one column family called `info`:

```text
create 'students', 'info'
```

Verify:

```text
list
```

Expected:

```text
students
```

Describe the table:

```text
describe 'students'
```

---

## 13. Insert Data

Insert a student:

```text
put 'students', '1', 'info:name', 'Merna'
```

Insert the course:

```text
put 'students', '1', 'info:course', 'Big Data'
```

Insert the score:

```text
put 'students', '1', 'info:score', '100'
```

Insert another student:

```text
put 'students', '2', 'info:name', 'Doha'
```

```text
put 'students', '2', 'info:course', 'Data Engineering'
```

```text
put 'students', '2', 'info:score', '95'
```

---

## 14. Read Data

Retrieve one row:

```text
get 'students', '1'
```

Retrieve a specific column:

```text
get 'students', '1', 'info:name'
```

Scan the entire table:

```text
scan 'students'
```

The scan should display both student records.

---

## 15. Update Data

HBase does not use a traditional SQL `UPDATE` statement.

Instead, writing another value to the same row and column replaces the current value.

For example:

```text
put 'students', '1', 'info:score', '98'
```

Then:

```text
get 'students', '1', 'info:score'
```

The returned value should be:

```text
98
```

---

## 16. Delete Data

Delete a specific cell:

```text
delete 'students', '1', 'info:score'
```

Verify:

```text
get 'students', '1'
```

Delete an entire row:

```text
deleteall 'students', '2'
```

Verify:

```text
scan 'students'
```

---

## 17. Drop the Test Table

Before dropping a table, disable it:

```text
disable 'students'
```

Then delete it:

```text
drop 'students'
```

Verify:

```text
list
```

---

## 18. HBase and HDFS

HBase stores its persistent data in HDFS.

Check the HBase directory:

```bash
hdfs dfs -ls /hbase
```

Depending on the HBase version and configuration, HDFS will contain HBase metadata and table directories.

This demonstrates the relationship:

```text
HBase
  │
  ▼
HDFS
  │
  ▼
Persistent distributed storage
```

HBase provides the database interface while HDFS provides the underlying distributed storage.

---

## 19. HBase Web Interfaces

HBase Master commonly provides a web interface on:

```text
http://localhost:16010
```

The RegionServer commonly uses:

```text
http://localhost:16030
```

If the pages do not load, verify the processes:

```bash
jps
```

and check the listening ports:

```bash
ss -lntp | grep -E '16010|16020|16030'
```

---

## 20. Common Problems

### `hbase: command not found`

Check:

```bash
echo $HBASE_HOME
```

Then:

```bash
which hbase
```

If necessary:

```bash
source ~/.bashrc
```

---

### HBase cannot find Hadoop

Verify:

```bash
echo $HADOOP_HOME
echo $HADOOP_CONF_DIR
```

Expected:

```text
/mnt/vol_e/bigdata/hadoop-3.3.6
/mnt/vol_e/bigdata/hadoop-3.3.6/etc/hadoop
```

Also verify:

```bash
ls $HADOOP_CONF_DIR
```

---

### HBase cannot connect to HDFS

Verify HDFS:

```bash
jps
```

Then:

```bash
hdfs dfs -ls /
```

If HDFS is not running:

```bash
start-dfs.sh
```

---

### Only `HMaster` appears in `jps`

Do not immediately assume HBase is completely broken.

Check HBase itself:

```bash
hbase shell
```

Then:

```text
status 'simple'
```

If it reports:

```text
1 live server
```

then the RegionServer is active even if the Java process list is not what you expected.

Also check:

```bash
ss -lntp | grep -E '16010|16020|16030'
```

---

### HBase fails because of Java

Check:

```bash
java -version
echo $JAVA_HOME
```

Then check:

```bash
grep JAVA_HOME $HBASE_HOME/conf/hbase-env.sh
```

Make sure HBase is using the Java version intended for this Hadoop/HBase setup.

---

### HBase starts but cannot create tables

Check the HBase status:

```bash
hbase shell
```

```text
status 'simple'
```

Then check HDFS permissions:

```bash
hdfs dfs -ls /
```

Also check the HBase logs:

```bash
ls -lah $HBASE_HOME/logs
```

---

### HBase reports a ZooKeeper problem

This setup uses HBase's managed ZooKeeper:

```bash
export HBASE_MANAGES_ZK=true
```

Check:

```bash
jps
```

A process such as:

```text
HQuorumPeer
```

may appear when HBase's embedded ZooKeeper is running.

---

## 21. Useful Commands

### Start HBase

```bash
start-hbase.sh
```

### Stop HBase

```bash
stop-hbase.sh
```

### Open HBase Shell

```bash
hbase shell
```

### Check HBase version

```bash
hbase version
```

### Check Java processes

```bash
jps
```

### Check HBase status

```bash
hbase shell
```

Then:

```text
status 'simple'
```

### Check HBase HDFS directory

```bash
hdfs dfs -ls /hbase
```

### Check HBase logs

```bash
ls -lah $HBASE_HOME/logs
```

---

## 22. Optional Startup Alias

The HBase startup command is already relatively short, but an alias can still be useful.

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
alias hbase-start='start-hbase.sh'
alias hbase-stop='stop-hbase.sh'
```

Reload:

```bash
source ~/.bashrc
```

Now:

```bash
hbase-start
```

starts HBase, while:

```bash
hbase-stop
```

stops it.

---

## 23. Installation Verification

Run:

```bash
hbase version
```

Verify the environment:

```bash
echo $HBASE_HOME
echo $HADOOP_HOME
```

Verify HDFS:

```bash
hdfs dfs -ls /
```

Start HBase:

```bash
start-hbase.sh
```

Check:

```bash
jps
```

Then:

```bash
hbase shell
```

Inside the shell:

```text
status 'simple'
```

Create a test table:

```text
create 'students', 'info'
```

Insert data:

```text
put 'students', '1', 'info:name', 'Merna'
put 'students', '1', 'info:course', 'Big Data'
put 'students', '1', 'info:score', '100'
```

Read it:

```text
get 'students', '1'
```

Scan the table:

```text
scan 'students'
```

If the data is returned successfully, the HBase installation is working.

Clean up:

```text
disable 'students'
drop 'students'
exit
```

---

## 24. Final Architecture

The resulting setup is:

```text
                    HBase
                      │
          ┌───────────┴───────────┐
          │                       │
       HMaster              RegionServer
          │                       │
          └───────────┬───────────┘
                      │
                  ZooKeeper
                      │
                      ▼
                    HDFS
                      │
              ┌───────┴───────┐
              │               │
          NameNode          DataNode
```

For this single-machine learning environment, the components run on the same Ubuntu system while maintaining the architecture used by a distributed HBase deployment.

The key relationship is:

```text
HBase → HDFS
```

HBase provides the NoSQL database layer, while HDFS provides persistent distributed storage.