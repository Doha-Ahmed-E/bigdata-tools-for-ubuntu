# Apache Hive Setup Guide

This guide explains how to install and configure Apache Hive on Ubuntu and integrate it with an existing Hadoop installation.

The setup assumes that Hadoop has already been installed and configured in:

```text
/mnt/vol_e/bigdata/hadoop-3.3.6
````

The guide uses a local/pseudo-distributed Hadoop installation.

---

## 1. Prerequisites

Before installing Hive, make sure Hadoop and Java are working.

### Check Java

```bash
java -version
echo $JAVA_HOME
```

For this setup, Java 8 is recommended for compatibility with the Hive version used here.

Expected:

```text
/usr/lib/jvm/java-8-openjdk-amd64
```

If Java 8 is installed but is not currently selected:

```bash
sudo update-alternatives --config java
```

Then select the Java 8 installation.

Verify:

```bash
java -version
```

---

## 2. Verify Hadoop

Check the Hadoop installation:

```bash
hadoop version
```

Expected:

```text
Hadoop 3.3.6
```

Check the environment:

```bash
echo $HADOOP_HOME
echo $HADOOP_CONF_DIR
```

Expected:

```text
/mnt/vol_e/bigdata/hadoop-3.3.6
/mnt/vol_e/bigdata/hadoop-3.3.6/etc/hadoop
```

Check that HDFS is running:

```bash
jps
```

You should normally see:

```text
NameNode
DataNode
SecondaryNameNode
```

If YARN is also running:

```text
ResourceManager
NodeManager
```

If HDFS is not running:

```bash
start-dfs.sh
```

If YARN is required:

```bash
start-yarn.sh
```

---

# 3. Create the Big Data Installation Directory

The tools in this environment are stored under `/mnt/vol_e/bigdata`.

```bash
mkdir -p /mnt/vol_e/bigdata
cd /mnt/vol_e/bigdata
```

---

# 4. Download Apache Hive

Choose a Hive version compatible with the Hadoop installation.

For this guide, Hive 3.1.3 is used.

Download it:

```bash
wget https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz
```

Verify that the archive exists:

```bash
ls -lh apache-hive-3.1.3-bin.tar.gz
```

---

# 5. Extract Hive

Extract the archive:

```bash
tar -xzf apache-hive-3.1.3-bin.tar.gz
```

Rename the extracted directory:

```bash
mv apache-hive-3.1.3-bin hive-3.1.3
```

The resulting installation should be:

```text
/mnt/vol_e/bigdata/hive-3.1.3
```

Verify:

```bash
ls /mnt/vol_e/bigdata/hive-3.1.3
```

You should see directories such as:

```text
bin
conf
lib
scripts
```

---

# 6. Configure Environment Variables

Add Hive to the shell environment.

Open:

```bash
nano ~/.bashrc
```

Add:

```bash
# Apache Hive
export HIVE_HOME=/mnt/vol_e/bigdata/hive-3.1.3
export PATH=$HIVE_HOME/bin:$PATH

# Hadoop configuration used by Hive
export HADOOP_HOME=/mnt/vol_e/bigdata/hadoop-3.3.6
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
```

Save the file and reload the environment:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $HIVE_HOME
echo $HADOOP_HOME
echo $HADOOP_CONF_DIR
```

Expected:

```text
/mnt/vol_e/bigdata/hive-3.1.3
/mnt/vol_e/bigdata/hadoop-3.3.6
/mnt/vol_e/bigdata/hadoop-3.3.6/etc/hadoop
```

Verify that Hive is available:

```bash
which hive
```

Expected:

```text
/mnt/vol_e/bigdata/hive-3.1.3/bin/hive
```

---

# 7. Configure Hive Environment

Hive provides a template configuration file.

Go to the Hive configuration directory:

```bash
cd $HIVE_HOME/conf
```

Copy the template:

```bash
cp hive-env.sh.template hive-env.sh
```

Open it:

```bash
nano hive-env.sh
```

Add or configure:

```bash
export HADOOP_HOME=/mnt/vol_e/bigdata/hadoop-3.3.6
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HIVE_HOME=/mnt/vol_e/bigdata/hive-3.1.3
```

Save the file.

---

# 8. Create Hive Configuration

Hive does not always provide a ready-to-use `hive-site.xml`.

Create it:

```bash
cd $HIVE_HOME/conf
nano hive-site.xml
```

For a simple local learning setup, use:

```xml
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>

    <!-- Hive warehouse location in HDFS -->
    <property>
        <name>hive.metastore.warehouse.dir</name>
        <value>/user/hive/warehouse</value>
    </property>

    <!-- Disable embedded Derby schema verification -->
    <property>
        <name>hive.metastore.schema.verification</name>
        <value>false</value>
    </property>

    <!-- Allow Hive to work with the local metastore -->
    <property>
        <name>hive.metastore.schema.verification.record.version</name>
        <value>false</value>
    </property>

    <!-- Use the local metastore -->
    <property>
        <name>javax.jdo.option.ConnectionURL</name>
        <value>jdbc:derby:;databaseName=/mnt/vol_e/bigdata/hive-3.1.3/metastore_db;create=true</value>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionDriverName</name>
        <value>org.apache.derby.jdbc.EmbeddedDriver</value>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionUserName</name>
        <value>APP</value>
    </property>

    <property>
        <name>javax.jdo.option.ConnectionPassword</name>
        <value>mine</value>
    </property>

</configuration>
```

This uses Hive's embedded Derby metastore.

> **Note:** Derby is convenient for learning and single-user experimentation. It is not appropriate as a production Hive metastore.

---

# 9. Create the Hive Warehouse Directory in HDFS

Hive needs a warehouse directory in HDFS.

Create it:

```bash
hdfs dfs -mkdir -p /user/hive/warehouse
```

Give the current user permission:

```bash
hdfs dfs -chmod -R 777 /user/hive/warehouse
```

Verify:

```bash
hdfs dfs -ls /user/hive
```

Expected:

```text
warehouse
```

---

# 10. Initialize the Hive Metastore

Hive uses a metastore to store metadata about databases, tables, columns, partitions, and other objects.

Initialize the Derby metastore:

```bash
schematool -dbType derby -initSchema
```

A successful initialization should end without an error and create the metastore database under:

```text
$HIVE_HOME/metastore_db
```

Check:

```bash
ls -d $HIVE_HOME/metastore_db
```

---

# 11. Verify Hive

Check the Hive version:

```bash
hive --version
```

Expected:

```text
Hive 3.1.3
```

Start the Hive CLI:

```bash
hive
```

You should see:

```text
hive>
```

---

# 12. Test Hive

Inside Hive:

```sql
SHOW DATABASES;
```

The default database should appear:

```text
default
```

Create a test database:

```sql
CREATE DATABASE hive_demo;
```

Check:

```sql
SHOW DATABASES;
```

Use the database:

```sql
USE hive_demo;
```

Create a table:

```sql
CREATE TABLE students (
    id INT,
    name STRING,
    course STRING,
    score INT
);
```

Check:

```sql
SHOW TABLES;
```

Expected:

```text
students
```

---

# 13. Insert Test Data

Insert a few records:

```sql
INSERT INTO students VALUES
(1, 'Merna', 'Big Data', 100),
(2, 'Ali', 'Big Data', 95),
(3, 'Sara', 'Data Engineering', 90),
(4, 'Omar', 'Data Engineering', 85);
```

Query the table:

```sql
SELECT * FROM students;
```

You should see the inserted records.

---

# 14. Test Hive with HDFS

Hive tables are backed by files stored in HDFS.

Find the warehouse directory:

```bash
hdfs dfs -ls /user/hive/warehouse
```

You should see the database directory.

For example:

```text
/user/hive/warehouse/hive_demo.db
```

Inspect it:

```bash
hdfs dfs -ls /user/hive/warehouse/hive_demo.db
```

You should see:

```text
students
```

Inspect the table directory:

```bash
hdfs dfs -ls /user/hive/warehouse/hive_demo.db/students
```

Hive has therefore successfully created HDFS data for the table.

---

# 15. Query HDFS Data

The table data can be viewed directly from HDFS.

First find the data file:

```bash
hdfs dfs -ls /user/hive/warehouse/hive_demo.db/students
```

Then:

```bash
hdfs dfs -cat /user/hive/warehouse/hive_demo.db/students/*
```

The output should contain the inserted records.

This demonstrates the relationship:

```text
Hive SQL
   │
   ▼
Hive Metastore
   │
   ▼
HDFS
   │
   ▼
Table Data
```

---

# 16. Test Aggregations

Hive can perform SQL-style analytics over HDFS data.

Inside Hive:

```sql
SELECT course, AVG(score)
FROM students
GROUP BY course;
```

You can also calculate counts:

```sql
SELECT course, COUNT(*)
FROM students
GROUP BY course;
```

And maximum scores:

```sql
SELECT MAX(score)
FROM students;
```

---

# 17. Create an External Table

Hive supports both managed and external tables.

Create a test directory:

```bash
hdfs dfs -mkdir -p /data/students
```

Create a CSV file locally:

```bash
cat > students.csv <<'EOF'
1,Merna,Big Data,100
2,Ali,Big Data,95
3,Sara,Data Engineering,90
4,Omar,Data Engineering,85
EOF
```

Upload it:

```bash
hdfs dfs -put students.csv /data/students/
```

Verify:

```bash
hdfs dfs -ls /data/students
```

Create an external Hive table:

```sql
CREATE EXTERNAL TABLE external_students (
    id INT,
    name STRING,
    course STRING,
    score INT
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
LOCATION '/data/students';
```

Query:

```sql
SELECT * FROM external_students;
```

The data is read directly from the HDFS location.

---

# 18. Managed vs External Tables

### Managed table

Example:

```sql
CREATE TABLE students (...);
```

Hive manages the table's data location.

Dropping the table can remove the associated data.

### External table

Example:

```sql
CREATE EXTERNAL TABLE external_students (...);
```

Hive manages the metadata, but the underlying data is considered externally managed.

Dropping the table does not normally remove the underlying HDFS data.

This distinction is important when designing Hive data warehouses.

---

# 19. Useful Hive Commands

Inside the Hive shell:

```sql
SHOW DATABASES;
```

List tables:

```sql
SHOW TABLES;
```

Describe a table:

```sql
DESCRIBE students;
```

Detailed table information:

```sql
DESCRIBE FORMATTED students;
```

Use a database:

```sql
USE hive_demo;
```

Drop a table:

```sql
DROP TABLE students;
```

Drop a database:

```sql
DROP DATABASE hive_demo;
```

Exit Hive:

```sql
EXIT;
```

---

# 20. Running Hive Queries from the Terminal

Instead of entering the interactive shell, a query can be passed directly:

```bash
hive -e "SHOW DATABASES;"
```

For example:

```bash
hive -e "USE hive_demo; SELECT * FROM students;"
```

This is useful when Hive commands need to be automated from shell scripts.

---

# 21. Common Problems

## Problem 1: `hive: command not found`

Check:

```bash
echo $HIVE_HOME
which hive
```

If necessary:

```bash
export HIVE_HOME=/mnt/vol_e/bigdata/hive-3.1.3
export PATH=$HIVE_HOME/bin:$PATH
```

Then:

```bash
source ~/.bashrc
```

---

## Problem 2: Java compatibility errors

Hive 3.1.3 is an older project and can have compatibility problems with newer Java versions.

Check:

```bash
java -version
```

If required, switch to Java 8:

```bash
sudo update-alternatives --config java
```

Then select:

```text
/usr/lib/jvm/java-8-openjdk-amd64
```

Also make sure:

```bash
echo $JAVA_HOME
```

matches the selected Java version.

---

## Problem 3: Hadoop is not available to Hive

Check:

```bash
echo $HADOOP_HOME
echo $HADOOP_CONF_DIR
```

Set:

```bash
export HADOOP_HOME=/mnt/vol_e/bigdata/hadoop-3.3.6
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
```

---

## Problem 4: Hive warehouse does not exist

Create it:

```bash
hdfs dfs -mkdir -p /user/hive/warehouse
```

Then:

```bash
hdfs dfs -chmod -R 777 /user/hive/warehouse
```

---

## Problem 5: Metastore initialization fails

Check whether an old Derby metastore already exists:

```bash
ls -la $HIVE_HOME/metastore_db
```

If this is a disposable learning installation and you want to completely reset the embedded metastore:

```bash
rm -rf $HIVE_HOME/metastore_db
```

Then initialize again:

```bash
schematool -dbType derby -initSchema
```

> **Warning:** Removing `metastore_db` deletes the Hive metastore metadata. Do this only when you are intentionally resetting the learning environment.

---

## Problem 6: `schematool` cannot initialize the schema

Check:

```bash
which schematool
```

Expected:

```text
/mnt/vol_e/bigdata/hive-3.1.3/bin/schematool
```

Check Java:

```bash
java -version
```

Check Hive:

```bash
echo $HIVE_HOME
```

Also verify that the Derby driver exists:

```bash
find $HIVE_HOME/lib -name '*derby*.jar'
```

---

## Problem 7: Hive cannot access HDFS

Check that Hadoop is running:

```bash
jps
```

You should have:

```text
NameNode
DataNode
SecondaryNameNode
```

Test HDFS directly:

```bash
hdfs dfs -ls /
```

If that fails, fix Hadoop/HDFS first.

Hive depends on the Hadoop configuration.

---

# 22. Resetting the Learning Installation

If you want to completely reset the local Hive metastore:

```bash
rm -rf $HIVE_HOME/metastore_db
```

Then:

```bash
schematool -dbType derby -initSchema
```

If you also want to remove the Hive warehouse:

```bash
hdfs dfs -rm -r /user/hive/warehouse
```

Recreate it:

```bash
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod -R 777 /user/hive/warehouse
```

Then recreate the Hive databases and tables.

---

# 23. Verification Checklist

Run:

```bash
java -version
```

```bash
hadoop version
```

```bash
hive --version
```

```bash
echo $HIVE_HOME
```

```bash
echo $HADOOP_HOME
```

Check Hadoop:

```bash
jps
```

Check HDFS:

```bash
hdfs dfs -ls /
```

Check Hive:

```bash
hive -e "SHOW DATABASES;"
```

Check the warehouse:

```bash
hdfs dfs -ls /user/hive/warehouse
```

A successful setup should allow:

```text
Ubuntu
  │
  ├── Java
  │
  ├── Hadoop
  │     ├── HDFS
  │     └── YARN
  │
  └── Hive
        ├── Hive CLI
        ├── Metastore
        └── HDFS Warehouse
```

---

# 24. Useful Commands Summary

### Start Hadoop

```bash
start-dfs.sh
start-yarn.sh
```

### Check Hadoop

```bash
jps
```

### Start Hive

```bash
hive
```

### Run a Hive query

```bash
hive -e "SHOW DATABASES;"
```

### Check HDFS

```bash
hdfs dfs -ls /
```

### Check Hive warehouse

```bash
hdfs dfs -ls /user/hive/warehouse
```

### Initialize the metastore

```bash
schematool -dbType derby -initSchema
```

### Stop Hadoop

```bash
stop-yarn.sh
stop-dfs.sh
```

---

# 25. Result

At the end of this guide, Hive should be able to:

* Connect to the existing Hadoop installation.
* Use HDFS as its storage layer.
* Maintain table metadata through the Hive Metastore.
* Create managed and external tables.
* Execute SQL queries over HDFS data.
* Perform aggregations such as `COUNT`, `AVG`, and `MAX`.
* Read external data stored directly in HDFS.

The resulting architecture is:

```text
                 Hive
                  │
        ┌─────────┴─────────┐
        │                   │
   Hive Metastore       Hive Query
        │                   │
        └─────────┬─────────┘
                  │
                 HDFS
                  │
          ┌───────┴───────┐
          │               │
      NameNode         DataNode
```

Hive provides the SQL/data-warehouse layer, while HDFS provides the distributed storage layer.