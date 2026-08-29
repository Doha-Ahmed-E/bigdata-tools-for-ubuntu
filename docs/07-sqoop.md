# Apache Sqoop 1.4.7

Apache Sqoop is a command-line tool for transferring bulk data between relational databases and Hadoop.

In this setup, PostgreSQL is used as the relational database and Hadoop HDFS is used as the destination.

> **Note:** Apache Sqoop 1.4.7 is an older project, so dependency and Java compatibility issues are common. The steps below are based on a Hadoop 3.3.6 environment.

---

## 1. Versions

| Component | Version |
|---|---|
| Apache Sqoop | 1.4.7 |
| Hadoop | 3.3.6 |
| PostgreSQL | 16.x |
| PostgreSQL JDBC Driver | 42.7.x |
| Java | OpenJDK 8 |
| OS | Ubuntu 24.04 |

Installation directory:

```text
/mnt/vol_e/bigdata/sqoop/sqoop-1.4.7.bin__hadoop-2.6.0
````

Although the extracted directory contains:

```text
hadoop-2.6.0
```

the Sqoop release itself is:

```text
Sqoop 1.4.7
```

---

## 2. Prerequisites

Sqoop requires:

* Java
* Hadoop
* A JDBC driver for the database being accessed

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
```

Expected:

```text
/mnt/vol_e/bigdata/hadoop-3.3.6
```

---

## 3. Download Sqoop

Move to the Big Data directory:

```bash
cd /mnt/vol_e/bigdata
```

Create the Sqoop directory:

```bash
mkdir -p sqoop
cd sqoop
```

Download Sqoop 1.4.7:

```bash
wget https://archive.apache.org/dist/sqoop/1.4.7/sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
```

Verify:

```bash
ls -lh sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
```

---

## 4. Extract Sqoop

Extract:

```bash
tar -xzf sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
```

Verify:

```bash
ls -lah
```

The installation directory should be:

```text
/mnt/vol_e/bigdata/sqoop/sqoop-1.4.7.bin__hadoop-2.6.0
```

Remove the archive:

```bash
rm sqoop-1.4.7.bin__hadoop-2.6.0.tar.gz
```

---

## 5. Configure Environment Variables

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
# Apache Sqoop
export SQOOP_HOME=/mnt/vol_e/bigdata/sqoop/sqoop-1.4.7.bin__hadoop-2.6.0
export PATH=$SQOOP_HOME/bin:$PATH

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
echo $SQOOP_HOME
which sqoop
```

Expected:

```text
/mnt/vol_e/bigdata/sqoop/sqoop-1.4.7.bin__hadoop-2.6.0
/mnt/vol_e/bigdata/sqoop/sqoop-1.4.7.bin__hadoop-2.6.0/bin/sqoop
```

---

## 6. Verify Sqoop

Run:

```bash
sqoop version
```

Expected:

```text
Sqoop 1.4.7
```

If Sqoop starts with warnings such as:

```text
HCatalog jobs will fail
Accumulo imports will fail
```

these warnings are not necessarily a problem.

They indicate that optional components are not installed.

For basic database imports, they can be ignored.

---

# PostgreSQL Setup

## 7. Install PostgreSQL

If PostgreSQL is not already installed:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

Verify:

```bash
psql --version
```

Expected:

```text
psql (PostgreSQL 16.x)
```

Check the service:

```bash
sudo systemctl status postgresql
```

If it is not running:

```bash
sudo systemctl start postgresql
```

---

## 8. Create a Database

Open PostgreSQL:

```bash
sudo -u postgres psql
```

Create a database:

```sql
CREATE DATABASE sqoop_demo;
```

Exit:

```sql
\q
```

Connect to the database:

```bash
psql sqoop_demo
```

---

## 9. Create a Test Table

Inside PostgreSQL:

```sql
CREATE TABLE employees (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER
);
```

Verify:

```sql
\dt
```

---

## 10. Insert Test Data

Insert sample records:

```sql
INSERT INTO employees VALUES
(1, 'Alice', 'Engineering', 80000),
(2, 'Bob', 'Data', 75000),
(3, 'Charlie', 'Engineering', 85000),
(4, 'Diana', 'HR', 65000),
(5, 'Eve', 'Data', 78000);
```

Check:

```sql
SELECT * FROM employees;
```

Expected:

```text
 id |  name   | department  | salary
----+---------+-------------+--------
  1 | Alice   | Engineering |  80000
  2 | Bob     | Data        |  75000
  3 | Charlie | Engineering |  85000
  4 | Diana   | HR          |  65000
  5 | Eve     | Data        |  78000
```

Exit:

```sql
\q
```

---

# PostgreSQL JDBC Driver

## 11. Download the PostgreSQL JDBC Driver

Sqoop needs a JDBC driver to communicate with PostgreSQL.

Go to the Sqoop `lib` directory:

```bash
cd $SQOOP_HOME/lib
```

Download a current PostgreSQL JDBC driver:

```bash
wget https://jdbc.postgresql.org/download/postgresql-42.7.7.jar
```

Verify:

```bash
ls | grep postgresql
```

Expected:

```text
postgresql-42.7.7.jar
```

> If a newer compatible 42.7.x driver is available, it can be used instead.

---

## 12. Verify the Driver

Check that the driver is actually inside Sqoop's library directory:

```bash
ls -lh $SQOOP_HOME/lib/postgresql-*.jar
```

The JDBC driver must be visible to Sqoop.

---

# PostgreSQL Authentication

## 13. Configure a Password

Sqoop needs to authenticate with PostgreSQL.

Connect as the PostgreSQL administrator:

```bash
sudo -u postgres psql
```

Set a password for the local user:

```sql
ALTER USER doha WITH PASSWORD 'YOUR_PASSWORD';
```

Replace:

```text
YOUR_PASSWORD
```

with your own password.

Exit:

```sql
\q
```

> Never commit the real password to Git.

---

## 14. Test PostgreSQL Login

Before using Sqoop, verify that the PostgreSQL credentials work:

```bash
psql -h localhost -U doha -d sqoop_demo -W
```

Enter the password when prompted.

Then:

```sql
SELECT * FROM employees;
```

If the rows are returned, PostgreSQL authentication is working.

Exit:

```sql
\q
```

---

# Sqoop Connection Test

## 15. List Database Tables

Before importing anything, test the JDBC connection.

Run:

```bash
sqoop list-tables \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P
```

Sqoop asks:

```text
Enter password:
```

Enter the PostgreSQL password.

Expected:

```text
employees
```

This confirms that:

```text
Sqoop → JDBC → PostgreSQL
```

is working.

---

# Import PostgreSQL Data into HDFS

## 16. Import a Table

Make sure HDFS is running:

```bash
jps
```

Expected Hadoop processes include:

```text
NameNode
DataNode
SecondaryNameNode
```

Import the `employees` table:

```bash
sqoop import \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P \
  --table employees \
  --target-dir /sqoop/employees
```

Sqoop will:

1. Connect to PostgreSQL.
2. Read the `employees` table.
3. Generate a MapReduce import job.
4. Transfer the data to HDFS.
5. Store the result under `/sqoop/employees`.

---

## 17. Verify the HDFS Output

List the directory:

```bash
hdfs dfs -ls /sqoop/employees
```

You should see one or more files such as:

```text
part-m-00000
```

or:

```text
part-m-00001
```

The exact number depends on the number of Sqoop mapper tasks.

---

## 18. Read the Imported Data

Run:

```bash
hdfs dfs -cat /sqoop/employees/*
```

The output should resemble:

```text
1,Alice,Engineering,80000
2,Bob,Data,75000
3,Charlie,Engineering,85000
4,Diana,HR,65000
5,Eve,Data,78000
```

This confirms:

```text
PostgreSQL
    │
    ▼
  Sqoop
    │
    ▼
  HDFS
```

---

# Import Options

## 19. Specify the Number of Mappers

Sqoop can parallelize the import using multiple mapper tasks.

For example:

```bash
sqoop import \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P \
  --table employees \
  --target-dir /sqoop/employees \
  --num-mappers 2
```

For small local datasets, one mapper is often sufficient.

```bash
--num-mappers 1
```

For learning, using multiple mappers is useful for demonstrating parallel imports.

---

## 20. Import Selected Columns

Use:

```bash
--columns
```

For example:

```bash
sqoop import \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P \
  --table employees \
  --columns id,name,department \
  --target-dir /sqoop/employees-basic
```

This imports only:

```text
id
name
department
```

and excludes:

```text
salary
```

---

## 21. Import Using a Query

Sqoop can import the result of a SQL query.

Example:

```bash
sqoop import \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P \
  --query "SELECT * FROM employees WHERE department = 'Data' AND \$CONDITIONS" \
  --target-dir /sqoop/data-employees \
  --num-mappers 1
```

The special:

```text
$CONDITIONS
```

placeholder allows Sqoop to add conditions required for parallel imports.

When using the command in a Bash shell, escape the `$`:

```text
\$CONDITIONS
```

---

# Export Data from HDFS to PostgreSQL

## 22. Create a Destination Table

Sqoop can also perform the reverse operation.

Create another PostgreSQL table:

```bash
psql -h localhost -U doha -d sqoop_demo -W
```

Then:

```sql
CREATE TABLE employees_copy (
    id INTEGER PRIMARY KEY,
    name VARCHAR(50),
    department VARCHAR(50),
    salary INTEGER
);
```

Exit:

```sql
\q
```

---

## 23. Export HDFS Data

Run:

```bash
sqoop export \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P \
  --table employees_copy \
  --export-dir /sqoop/employees \
  --input-fields-terminated-by ','
```

Sqoop reads the files from:

```text
/sqoop/employees
```

and inserts the records into:

```text
employees_copy
```

---

## 24. Verify the Export

Connect to PostgreSQL:

```bash
psql -h localhost -U doha -d sqoop_demo -W
```

Run:

```sql
SELECT * FROM employees_copy;
```

The imported records should appear.

---

# Common Problems

## `NoClassDefFoundError: org/apache/commons/lang/StringUtils`

One of the important Sqoop compatibility problems is the Commons Lang dependency.

The error looks like:

```text
java.lang.NoClassDefFoundError:
org/apache/commons/lang/StringUtils
```

Check the Sqoop libraries:

```bash
ls $SQOOP_HOME/lib | grep commons-lang
```

You may see:

```text
commons-lang3-3.4.jar
```

Hadoop may contain a different version:

```bash
ls $HADOOP_HOME/share/hadoop/common/lib | grep commons-lang
```

For example:

```text
commons-lang3-3.12.0.jar
```

The important distinction is:

```text
commons-lang
```

versus:

```text
commons-lang3
```

They use different Java package names.

Sqoop 1.4.7 expects the older Commons Lang package:

```text
org.apache.commons.lang.StringUtils
```

while Commons Lang 3 uses:

```text
org.apache.commons.lang3.StringUtils
```

Therefore, installing only `commons-lang3` does not solve this particular error.

---

## SCRAM Authentication Error

A PostgreSQL connection may fail with:

```text
The server requested SCRAM-based authentication,
but the password is an empty string.
```

This usually means that Sqoop did not receive a password.

Use:

```bash
-P
```

and enter the password when prompted:

```bash
sqoop list-tables \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P
```

Avoid putting passwords directly into commands or committed configuration files.

---

## PostgreSQL JDBC Driver Not Found

If Sqoop cannot connect to PostgreSQL, verify:

```bash
ls $SQOOP_HOME/lib | grep postgresql
```

You should see something like:

```text
postgresql-42.7.7.jar
```

If nothing appears, download the driver again.

---

## PostgreSQL Connection Refused

Check PostgreSQL:

```bash
sudo systemctl status postgresql
```

Start it if necessary:

```bash
sudo systemctl start postgresql
```

Test:

```bash
psql -h localhost -U doha -d sqoop_demo -W
```

---

## HDFS Is Not Running

Check:

```bash
jps
```

If `NameNode` and `DataNode` are missing:

```bash
start-dfs.sh
```

Then:

```bash
hdfs dfs -ls /
```

---

## Target Directory Already Exists

Sqoop will normally refuse to import into an existing target directory.

You may see an error indicating that:

```text
Target directory already exists
```

Remove the test directory if you want to repeat the import:

```bash
hdfs dfs -rm -r /sqoop/employees
```

Then run the import again.

> Be careful with `hdfs dfs -rm -r`. Make sure the path is the directory you actually intend to delete.

---

## HCatalog / Accumulo / ZooKeeper Warnings

Sqoop may display warnings such as:

```text
HCatalog does not exist
Accumulo does not exist
ZooKeeper does not exist
```

These are optional Sqoop integrations.

They do not prevent a normal JDBC table import.

For example:

```text
Warning: .../hcatalog does not exist!
```

does not mean that PostgreSQL connectivity has failed.

---

# Useful Commands

## Check Sqoop version

```bash
sqoop version
```

## List PostgreSQL tables

```bash
sqoop list-tables \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P
```

## Import a table

```bash
sqoop import \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P \
  --table employees \
  --target-dir /sqoop/employees
```

## Check HDFS output

```bash
hdfs dfs -ls /sqoop/employees
```

## Read imported data

```bash
hdfs dfs -cat /sqoop/employees/*
```

## Remove imported data

```bash
hdfs dfs -rm -r /sqoop/employees
```

## Check PostgreSQL

```bash
psql -h localhost -U doha -d sqoop_demo -W
```

## Check Hadoop processes

```bash
jps
```

---

# Installation Verification

Run:

```bash
sqoop version
```

Verify:

```bash
echo $SQOOP_HOME
```

Verify the JDBC driver:

```bash
ls $SQOOP_HOME/lib | grep postgresql
```

Verify PostgreSQL:

```bash
psql -h localhost -U doha -d sqoop_demo -W
```

Inside PostgreSQL:

```sql
SELECT * FROM employees;
```

Exit:

```sql
\q
```

Verify HDFS:

```bash
hdfs dfs -ls /
```

Test Sqoop:

```bash
sqoop list-tables \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P
```

Expected:

```text
employees
```

Finally, import:

```bash
sqoop import \
  --connect jdbc:postgresql://localhost:5432/sqoop_demo \
  --username doha \
  -P \
  --table employees \
  --target-dir /sqoop/employees
```

Verify:

```bash
hdfs dfs -cat /sqoop/employees/*
```

If the employee records are displayed, the Sqoop → PostgreSQL → HDFS pipeline is working.

---

# Final Architecture

The completed Sqoop setup provides two directions of data movement:

```text
             IMPORT

PostgreSQL
    │
    ▼
  Sqoop
    │
    ▼
   HDFS
```

and:

```text
             EXPORT

   HDFS
    │
    ▼
  Sqoop
    │
    ▼
PostgreSQL
```

Sqoop therefore acts as a bridge between the relational database world and the Hadoop ecosystem.