# Apache Spark 3.5.1

Apache Spark is a distributed data-processing engine used for large-scale batch processing, SQL analytics, machine learning, and streaming.

This guide installs Apache Spark 3.5.1 with Hadoop 3 support and configures it to work with the Hadoop/YARN environment created in this repository.

## 1. Version

This guide uses:

| Component | Version |
|---|---|
| Apache Spark | 3.5.1 |
| Hadoop | 3.3.6 |
| Scala | 2.12.18 |
| Java | OpenJDK 17 |
| Python | 3.x |

The Spark distribution used is:

```text
spark-3.5.1-bin-hadoop3
````

---

## 2. Prerequisites

Before installing Spark, make sure Hadoop is already installed and working.

Verify Hadoop:

```bash
hadoop version
```

Verify Java:

```bash
java -version
```

Verify the Java environment:

```bash
echo $JAVA_HOME
```

For this setup:

```text
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
```

> Spark 3.5.1 works with Java 17. Hadoop compatibility should still be checked against the Hadoop version used by the environment.

---

## 3. Download Spark

Move to the Big Data installation directory:

```bash
cd /mnt/vol_e/bigdata
```

Create the Spark directory:

```bash
mkdir -p spark
cd spark
```

Download Spark 3.5.1 with Hadoop 3 support:

```bash
wget https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz
```

Verify that the archive exists:

```bash
ls -lh spark-3.5.1-bin-hadoop3.tgz
```

---

## 4. Extract Spark

Extract the archive:

```bash
tar -xzf spark-3.5.1-bin-hadoop3.tgz
```

Verify:

```bash
ls -lah
```

The extracted directory should be:

```text
/mnt/vol_e/bigdata/spark/spark-3.5.1-bin-hadoop3
```

Optional: remove the downloaded archive after extraction:

```bash
rm spark-3.5.1-bin-hadoop3.tgz
```

---

## 5. Configure Environment Variables

Open the shell configuration:

```bash
nano ~/.bashrc
```

Add:

```bash
# Apache Spark
export SPARK_HOME=/mnt/vol_e/bigdata/spark/spark-3.5.1-bin-hadoop3
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH

# Hadoop configuration for Spark
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export YARN_CONF_DIR=$HADOOP_HOME/etc/hadoop
```

Save the file and reload the shell configuration:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $SPARK_HOME
which spark-submit
```

Expected:

```text
/mnt/vol_e/bigdata/spark/spark-3.5.1-bin-hadoop3
/mnt/vol_e/bigdata/spark/spark-3.5.1-bin-hadoop3/bin/spark-submit
```

---

## 6. Verify Spark

Check the Spark version:

```bash
spark-submit --version
```

Expected output includes:

```text
version 3.5.1
```

The output should also show the Java and Scala versions used by Spark.

Another useful command is:

```bash
pyspark --version
```

---

## 7. Test Spark in Local Mode

Spark can run without Hadoop/YARN using local mode.

Run:

```bash
spark-shell --master local[*]
```

Inside the Spark shell:

```scala
sc.version
```

Expected:

```text
res0: String = 3.5.1
```

Exit:

```scala
:quit
```

---

## 8. Test PySpark

Start PySpark:

```bash
pyspark --master local[*]
```

Test the Spark version:

```python
spark.version
```

Expected:

```text
'3.5.1'
```

Create a small DataFrame:

```python
data = [
    ("Alice", 90),
    ("Bob", 85),
    ("Charlie", 95)
]

df = spark.createDataFrame(data, ["name", "score"])
df.show()
```

Expected output:

```text
+-------+-----+
|   name|score|
+-------+-----+
|  Alice|   90|
|    Bob|   85|
|Charlie|   95|
+-------+-----+
```

Exit:

```python
exit()
```

---

## 9. Create a Spark Application

Create a directory for Spark applications:

```bash
mkdir -p ~/spark-labs
cd ~/spark-labs
```

Create a test application:

```bash
nano test_spark.py
```

Add:

```python
from pyspark.sql import SparkSession


def main():
    spark = (
        SparkSession.builder
        .appName("SparkTest")
        .getOrCreate()
    )

    data = [
        ("Alice", "IT", 5000),
        ("Bob", "HR", 4200),
        ("Charlie", "Sales", 6100),
        ("Diana", "Finance", 7000),
    ]

    df = spark.createDataFrame(
        data,
        ["name", "department", "salary"]
    )

    df.show()

    df.groupBy("department").avg("salary").show()

    spark.stop()


if __name__ == "__main__":
    main()
```

Run it:

```bash
spark-submit --master local[*] test_spark.py
```

Spark should create the DataFrame and display the grouped average salaries.

---

## 10. Run Spark with YARN

Spark can use YARN as its cluster manager.

First make sure Hadoop and YARN are running:

```bash
jps
```

Expected Hadoop/YARN processes include:

```text
NameNode
DataNode
SecondaryNameNode
ResourceManager
NodeManager
```

Verify the YARN ResourceManager:

```bash
yarn node -list
```

Then submit the Spark application to YARN:

```bash
spark-submit \
  --master yarn \
  test_spark.py
```

Spark will submit the application to YARN instead of running entirely in the local JVM.

---

## 11. Spark + HDFS

Spark can read and write files stored in HDFS.

Create a test directory:

```bash
hdfs dfs -mkdir -p /spark/input
```

Create a local test file:

```bash
echo "Alice,90" > students.csv
echo "Bob,85" >> students.csv
echo "Charlie,95" >> students.csv
```

Upload it to HDFS:

```bash
hdfs dfs -put students.csv /spark/input/
```

Verify:

```bash
hdfs dfs -ls /spark/input
```

Read the file:

```bash
hdfs dfs -cat /spark/input/students.csv
```

---

## 12. Read HDFS Data with PySpark

Create:

```bash
nano hdfs_test.py
```

Add:

```python
from pyspark.sql import SparkSession


def main():
    spark = (
        SparkSession.builder
        .appName("HDFSTest")
        .getOrCreate()
    )

    df = (
        spark.read
        .option("header", "false")
        .option("inferSchema", "true")
        .csv("hdfs:///spark/input/students.csv")
    )

    df.show()

    spark.stop()


if __name__ == "__main__":
    main()
```

Run locally:

```bash
spark-submit \
  --master local[*] \
  hdfs_test.py
```

Spark should read the CSV directly from HDFS.

---

## 13. Spark SQL

Spark includes a SQL engine that can query DataFrames and tables.

Example:

```python
df.createOrReplaceTempView("students")
```

Then:

```python
result = spark.sql("""
    SELECT *
    FROM students
    WHERE score >= 90
""")

result.show()
```

Spark SQL can also be used with Hive integration when Hive support is configured.

---

## 14. Spark with Hive

If Hive is installed and configured, Spark can enable Hive support:

```python
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .appName("SparkHive")
    .enableHiveSupport()
    .getOrCreate()
)
```

Check available tables:

```python
spark.sql("SHOW TABLES").show()
```

This allows Spark SQL to interact with the Hive metastore.

---

## 15. Useful Spark Commands

### Version

```bash
spark-submit --version
```

### PySpark

```bash
pyspark
```

### Scala Spark shell

```bash
spark-shell
```

### Submit locally

```bash
spark-submit --master local[*] application.py
```

### Submit to YARN

```bash
spark-submit --master yarn application.py
```

### List YARN applications

```bash
yarn application -list
```

### Kill a YARN application

```bash
yarn application -kill <application_id>
```

---

## 16. Common Problems

### `spark-submit: command not found`

Check:

```bash
echo $SPARK_HOME
```

and:

```bash
echo $PATH
```

Make sure:

```bash
$SPARK_HOME/bin
```

is included in `PATH`.

Reload:

```bash
source ~/.bashrc
```

---

### Spark cannot connect to YARN

Check:

```bash
echo $HADOOP_CONF_DIR
echo $YARN_CONF_DIR
```

Both should point to:

```text
$HADOOP_HOME/etc/hadoop
```

Also verify that YARN is running:

```bash
jps
```

and:

```bash
yarn node -list
```

---

### Spark hostname warning

You may see:

```text
WARN Utils:
Your hostname ... resolves to a loopback address
```

Spark may then report:

```text
using 192.168.x.x instead
```

This is generally only a warning on a single-machine installation.

If Spark needs to bind to a specific local address, set:

```bash
export SPARK_LOCAL_IP=192.168.1.16
```

Replace the address with the machine's actual IP address.

For a normal single-machine learning environment, this warning does not necessarily require a fix.

---

### Java version problems

Check:

```bash
java -version
echo $JAVA_HOME
```

Spark 3.5.1 supports Java 17.

If multiple Java versions are installed, make sure `JAVA_HOME` points to the intended version.

---

### Spark application hangs

Check whether the application was submitted to YARN:

```bash
yarn application -list
```

Also check:

```bash
jps
```

If using YARN, verify that:

```text
ResourceManager
NodeManager
```

are running.

---

## 17. Stopping Spark

Spark applications normally terminate automatically when the application finishes.

For an interactive shell:

```text
:quit
```

or:

```python
exit()
```

If Spark is being run through YARN, check running applications:

```bash
yarn application -list
```

and terminate a specific application if necessary:

```bash
yarn application -kill <application_id>
```

---

## 18. Optional Alias

Spark commands can be shortened with aliases.

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
alias pyspark-local='pyspark --master local[*]'
alias spark-local='spark-submit --master local[*]'
alias spark-yarn='spark-submit --master yarn'
```

Reload:

```bash
source ~/.bashrc
```

Now:

```bash
pyspark-local
```

starts PySpark locally, while:

```bash
spark-yarn application.py
```

submits an application to YARN.

---

## 19. Installation Verification Checklist

Run:

```bash
java -version
```

```bash
hadoop version
```

```bash
spark-submit --version
```

```bash
echo $SPARK_HOME
```

```bash
echo $HADOOP_CONF_DIR
```

```bash
echo $YARN_CONF_DIR
```

Then verify Hadoop/YARN:

```bash
jps
```

and:

```bash
yarn node -list
```

Finally test Spark locally:

```bash
spark-submit \
  --master local[*] \
  test_spark.py
```

and, if YARN is running:

```bash
spark-submit \
  --master yarn \
  test_spark.py
```

A successful local and YARN submission confirms that Spark is correctly integrated with the Hadoop environment.

---

## 20. Installation Paths

For this guide, the relevant paths are:

```text
/mnt/vol_e/bigdata/
└── spark/
    └── spark-3.5.1-bin-hadoop3/
```

Spark configuration files are located under:

```text
$SPARK_HOME/conf/
```

Hadoop configuration is located under:

```text
$HADOOP_HOME/etc/hadoop/
```

The main Spark executable directory is:

```text
$SPARK_HOME/bin/
```

The Spark administrative scripts are:

```text
$SPARK_HOME/sbin/
```

---

## 21. Summary

The resulting architecture is:

```text
                 Apache Spark 3.5.1
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       Local[*]        YARN          Spark SQL
          │              │              │
          │              ▼              │
          │       ResourceManager       │
          │              │              │
          │        NodeManager          │
          │              │              │
          └──────────────┼──────────────┘
                         │
                        HDFS
                         │
                  ┌──────┴──────┐
                  │             │
              NameNode       DataNode
```

Spark can therefore be used in two main ways in this environment:

```text
spark-submit --master local[*]
```

for local development and testing, and:

```text
spark-submit --master yarn
```

for distributed execution through Hadoop YARN.