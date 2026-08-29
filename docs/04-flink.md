# Apache Flink 1.20.2

Apache Flink is a distributed processing framework designed primarily for stateful stream processing, while also supporting batch workloads.

This guide installs Apache Flink 1.20.2 and configures it to work with the Hadoop environment used in this repository.

---

## 1. Version

This guide uses:

| Component | Version |
|---|---|
| Apache Flink | 1.20.2 |
| Hadoop | 3.3.6 |
| Java | OpenJDK 17 |
| OS | Ubuntu 24.04 |

Installation directory:

```text
/mnt/vol_e/bigdata/flink/flink-1.20.2
````

---

## 2. Prerequisites

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

For this setup:

```text
HADOOP_HOME=/mnt/vol_e/bigdata/hadoop-3.3.6
HADOOP_CONF_DIR=/mnt/vol_e/bigdata/hadoop-3.3.6/etc/hadoop
```

---

## 3. Download Flink

Move to the Big Data installation directory:

```bash
cd /mnt/vol_e/bigdata
```

Create the Flink directory:

```bash
mkdir -p flink
cd flink
```

Download Flink 1.20.2:

```bash
wget https://archive.apache.org/dist/flink/flink-1.20.2/flink-1.20.2-bin-scala_2.12.tgz
```

Verify the archive:

```bash
ls -lh flink-1.20.2-bin-scala_2.12.tgz
```

---

## 4. Extract Flink

Extract the archive:

```bash
tar -xzf flink-1.20.2-bin-scala_2.12.tgz
```

Verify:

```bash
ls -lah
```

The installation directory should be:

```text
/mnt/vol_e/bigdata/flink/flink-1.20.2
```

The archive can optionally be removed:

```bash
rm flink-1.20.2-bin-scala_2.12.tgz
```

---

## 5. Configure Environment Variables

Edit the shell configuration:

```bash
nano ~/.bashrc
```

Add:

```bash
# Apache Flink
export FLINK_HOME=/mnt/vol_e/bigdata/flink/flink-1.20.2
export PATH=$FLINK_HOME/bin:$PATH

# Hadoop integration
export HADOOP_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $FLINK_HOME
which flink
```

Expected:

```text
/mnt/vol_e/bigdata/flink/flink-1.20.2
/mnt/vol_e/bigdata/flink/flink-1.20.2/bin/flink
```

---

## 6. Verify Flink

Run:

```bash
flink --version
```

Expected:

```text
Version: 1.20.2
```

---

## 7. Configure Flink

Flink configuration files are located at:

```text
$FLINK_HOME/conf/
```

The main configuration file is:

```text
$FLINK_HOME/conf/config.yaml
```

The default configuration is sufficient for a basic local installation.

For a learning environment, Flink can initially be run as a standalone local cluster.

---

## 8. Start a Local Flink Cluster

Start the Flink cluster:

```bash
$FLINK_HOME/bin/start-cluster.sh
```

Check the Java processes:

```bash
jps
```

A running Flink installation should include processes such as:

```text
StandaloneSessionClusterEntrypoint
TaskManagerRunner
```

Flink also provides a web interface.

Open:

```text
http://localhost:8081
```

The Flink Dashboard displays:

* JobManager status
* TaskManagers
* Running jobs
* Completed jobs
* Available task slots

---

## 9. Run the Flink WordCount Example

Flink includes example JAR files.

Find them with:

```bash
find $FLINK_HOME/examples -name "*.jar"
```

The WordCount example can be submitted with:

```bash
flink run \
  $FLINK_HOME/examples/batch/WordCount.jar
```

Depending on the distribution, the exact example location may differ.

If the example JAR is located elsewhere, search for it:

```bash
find $FLINK_HOME -iname "*WordCount*.jar"
```

Then use the returned path with:

```bash
flink run <path-to-wordcount-jar>
```

---

## 10. Flink and HDFS

Flink can access Hadoop/HDFS when the appropriate Hadoop configuration and libraries are available.

Verify the Hadoop classpath:

```bash
echo $HADOOP_CLASSPATH
```

It should contain Hadoop JAR files.

A useful check is:

```bash
hadoop classpath
```

---

## 11. HDFS Integration Problem

A common error when Flink attempts to access HDFS is:

```text
UnsupportedFileSystemException:
No FileSystem for scheme "hdfs"
```

This means Flink cannot find the Hadoop filesystem implementation.

For this setup, configure:

```bash
export HADOOP_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)
```

Then restart the shell:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $HADOOP_CLASSPATH
```

If Flink was already running, restart the Flink cluster:

```bash
$FLINK_HOME/bin/stop-cluster.sh
$FLINK_HOME/bin/start-cluster.sh
```

---

## 12. Test HDFS Access

Create a test directory:

```bash
hdfs dfs -mkdir -p /flink/input
```

Create a test file:

```bash
echo "hello flink" > flink-test.txt
```

Upload it:

```bash
hdfs dfs -put flink-test.txt /flink/input/
```

Verify:

```bash
hdfs dfs -ls /flink/input
```

Read it:

```bash
hdfs dfs -cat /flink/input/flink-test.txt
```

---

## 13. Flink Web Dashboard

With the local cluster running, open:

```text
http://localhost:8081
```

The dashboard can be used to inspect:

```text
JobManager
TaskManagers
Jobs
Task Slots
```

This is useful for verifying that the Flink cluster is actually running rather than relying only on terminal output.

---

## 14. Useful Flink Commands

### Check version

```bash
flink --version
```

### Start cluster

```bash
$FLINK_HOME/bin/start-cluster.sh
```

### Stop cluster

```bash
$FLINK_HOME/bin/stop-cluster.sh
```

### List running jobs

```bash
flink list
```

### Submit a job

```bash
flink run <job.jar>
```

### Cancel a job

```bash
flink cancel <job_id>
```

### Find example JARs

```bash
find $FLINK_HOME/examples -name "*.jar"
```

### Check Flink processes

```bash
jps
```

---

## 15. Optional Aliases

To simplify cluster management, edit:

```bash
nano ~/.bashrc
```

Add:

```bash
alias flink-start='$FLINK_HOME/bin/start-cluster.sh'
alias flink-stop='$FLINK_HOME/bin/stop-cluster.sh'
alias flink-jobs='flink list'
```

Reload:

```bash
source ~/.bashrc
```

Then:

```bash
flink-start
```

starts the cluster.

```bash
flink-jobs
```

lists jobs.

```bash
flink-stop
```

stops the cluster.

---

## 16. Common Problems

### `flink: command not found`

Check:

```bash
echo $FLINK_HOME
```

and:

```bash
echo $PATH
```

Make sure:

```text
$FLINK_HOME/bin
```

is included in `PATH`.

Reload:

```bash
source ~/.bashrc
```

---

### HDFS scheme is not supported

Error:

```text
No FileSystem for scheme "hdfs"
```

Set:

```bash
export HADOOP_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)
```

Then restart Flink:

```bash
flink-stop
flink-start
```

---

### Flink cluster does not start

Check the logs:

```bash
ls -lah $FLINK_HOME/log
```

Inspect the latest log:

```bash
tail -n 50 $FLINK_HOME/log/*.log
```

Also check:

```bash
jps
```

---

### Port 8081 is already in use

Check:

```bash
sudo lsof -i :8081
```

If another Flink process is running, stop it:

```bash
flink-stop
```

Then restart:

```bash
flink-start
```

---

### Java compatibility problems

Check:

```bash
java -version
echo $JAVA_HOME
```

Flink 1.20.2 supports modern Java versions, but the exact Java version should be kept consistent with the rest of the environment where possible.

---

## 17. Stopping Flink

Stop the local Flink cluster:

```bash
$FLINK_HOME/bin/stop-cluster.sh
```

Verify:

```bash
jps
```

The Flink JobManager and TaskManager processes should no longer be present.

---

## 18. Installation Verification Checklist

Run:

```bash
java -version
```

```bash
hadoop version
```

```bash
flink --version
```

```bash
echo $FLINK_HOME
```

```bash
echo $HADOOP_HOME
```

```bash
echo $HADOOP_CLASSPATH
```

Start Flink:

```bash
flink-start
```

Verify:

```bash
jps
```

Then open:

```text
http://localhost:8081
```

Finally:

```bash
flink list
```

A successful dashboard connection and running Flink processes confirm that the installation is working.

---

## 19. Installation Paths

The main installation:

```text
/mnt/vol_e/bigdata/flink/flink-1.20.2
```

Configuration:

```text
$FLINK_HOME/conf/
```

Logs:

```text
$FLINK_HOME/log/
```

Executables:

```text
$FLINK_HOME/bin/
```

Examples:

```text
$FLINK_HOME/examples/
```

---

## 20. Summary

The resulting relationship between Flink and the existing Hadoop environment is:

```text
                Apache Flink 1.20.2
                         │
             ┌───────────┴───────────┐
             │                       │
        Local Cluster              HDFS
             │                       │
        ┌────┴────┐                   │
        │         │                   │
   JobManager  TaskManager            │
        │         │                   │
        └────┬────┘                   │
             │                        │
             └───────────┬────────────┘
                         │
                    Hadoop 3.3.6
```

Flink can operate independently as a processing engine while using HDFS as a storage layer.

The Hadoop classpath is important when Flink needs to interact with HDFS:

```bash
export HADOOP_CLASSPATH=$($HADOOP_HOME/bin/hadoop classpath)
```

The basic workflow is:

```bash
flink-start
```

then submit a job:

```bash
flink run <job.jar>
```

and inspect it through:

```text
http://localhost:8081
```

When finished:

```bash
flink-stop
```