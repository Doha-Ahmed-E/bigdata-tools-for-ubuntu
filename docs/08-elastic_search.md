# ELK Stack

The ELK Stack consists of:

- **Elasticsearch** — search and analytics engine
- **Logstash** — data ingestion and processing pipeline
- **Kibana** — visualization and exploration interface

The components are used together as:

```text
Data Source
     │
     ▼
 Logstash
     │
     ▼
Elasticsearch
     │
     ▼
  Kibana
````

This guide uses Elasticsearch, Logstash, and Kibana version **8.17.10**.

---

## 1. Versions

| Component     | Version                  |
| ------------- | ------------------------ |
| Elasticsearch | 8.17.10                  |
| Logstash      | 8.17.10                  |
| Kibana        | 8.17.10                  |
| Java          | OpenJDK 17 / bundled JDK |
| OS            | Ubuntu 24.04             |

Installation directory:

```text
/mnt/vol_e/bigdata/
├── elasticsearch/
├── logstash/
└── kibana/
```

> Elasticsearch and Kibana should use matching versions. The same principle applies to Logstash.

---

# Elasticsearch

## 2. Download Elasticsearch

Move to the Big Data directory:

```bash
cd /mnt/vol_e/bigdata
```

Create the Elasticsearch directory:

```bash
mkdir -p elasticsearch
cd elasticsearch
```

Download Elasticsearch 8.17.10:

```bash
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.17.10-linux-x86_64.tar.gz
```

Verify:

```bash
ls -lh elasticsearch-8.17.10-linux-x86_64.tar.gz
```

---

## 3. Extract Elasticsearch

Extract:

```bash
tar -xzf elasticsearch-8.17.10-linux-x86_64.tar.gz
```

Verify:

```bash
ls -lah
```

The installation should be:

```text
/mnt/vol_e/bigdata/elasticsearch/elasticsearch-8.17.10
```

The archive can then be removed:

```bash
rm elasticsearch-8.17.10-linux-x86_64.tar.gz
```

---

## 4. Configure Elasticsearch Environment Variables

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
# Elasticsearch
export ELASTICSEARCH_HOME=/mnt/vol_e/bigdata/elasticsearch/elasticsearch-8.17.10
export PATH=$ELASTICSEARCH_HOME/bin:$PATH
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $ELASTICSEARCH_HOME
which elasticsearch
```

Expected:

```text
/mnt/vol_e/bigdata/elasticsearch/elasticsearch-8.17.10
/mnt/vol_e/bigdata/elasticsearch/elasticsearch-8.17.10/bin/elasticsearch
```

---

## 5. Verify Elasticsearch

Run:

```bash
elasticsearch --version
```

Expected:

```text
Version: 8.17.10
```

Elasticsearch 8.17.10 includes a bundled JDK, so it may display:

```text
warning: ignoring JAVA_HOME=...; using bundled JDK
```

This is normal.

---

# 6. Start Elasticsearch

Start Elasticsearch:

```bash
elasticsearch
```

The first startup automatically configures security.

The terminal displays:

* Password for the `elastic` user
* HTTP CA certificate fingerprint
* Kibana enrollment token

Example:

```text
Password for the elastic user:
...
HTTP CA certificate SHA-256 fingerprint:
...
Configure Kibana to use this cluster:
...
```

### Important

Save the generated `elastic` password somewhere secure.

Do **not**:

* commit it to Git
* put it in the repository
* put it in screenshots
* publish it in the README

The same applies to the Kibana enrollment token.

---

## 7. Verify Elasticsearch with curl

Keep Elasticsearch running in its terminal.

Open a second terminal.

Test:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200
```

Enter the `elastic` password when prompted.

A successful response contains information about the Elasticsearch node and version.

---

## 8. Check Cluster Health

Run:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/_cluster/health?pretty
```

A single-node development cluster should eventually report:

```json
{
  "status": "green"
}
```

A temporary `yellow` status during startup can be normal while shards are being allocated.

---

# Kibana

## 9. Download Kibana

Open another terminal.

Move to:

```bash
cd /mnt/vol_e/bigdata
```

Create the directory:

```bash
mkdir -p kibana
cd kibana
```

Download Kibana 8.17.10:

```bash
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.17.10-linux-x86_64.tar.gz
```

Verify:

```bash
ls -lh kibana-8.17.10-linux-x86_64.tar.gz
```

---

## 10. Extract Kibana

```bash
tar -xzf kibana-8.17.10-linux-x86_64.tar.gz
```

Verify:

```bash
ls -lah
```

The installation should be:

```text
/mnt/vol_e/bigdata/kibana/kibana-8.17.10
```

Remove the archive:

```bash
rm kibana-8.17.10-linux-x86_64.tar.gz
```

---

## 11. Configure Kibana Environment Variables

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
# Kibana
export KIBANA_HOME=/mnt/vol_e/bigdata/kibana/kibana-8.17.10
export PATH=$KIBANA_HOME/bin:$PATH
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $KIBANA_HOME
which kibana
```

---

## 12. Start Kibana

Make sure Elasticsearch is already running.

Then run:

```bash
kibana
```

Kibana will display a URL similar to:

```text
http://localhost:5601
```

Open the URL in a browser.

---

## 13. Connect Kibana to Elasticsearch

On first startup, Kibana provides an enrollment process.

Use the enrollment token generated by Elasticsearch.

If the token has expired, generate a new one from the Elasticsearch installation:

```bash
$ELASTICSEARCH_HOME/bin/elasticsearch-create-enrollment-token -s kibana
```

Copy the generated token into Kibana when requested.

Once setup is complete, open:

```text
http://localhost:5601
```

Log in with:

```text
Username: elastic
Password: <your Elasticsearch password>
```

---

# Logstash

## 14. Download Logstash

Move to:

```bash
cd /mnt/vol_e/bigdata
```

Create the directory:

```bash
mkdir -p logstash
cd logstash
```

Download Logstash 8.17.10:

```bash
wget https://artifacts.elastic.co/downloads/logstash/logstash-8.17.10-linux-x86_64.tar.gz
```

Verify:

```bash
ls -lh logstash-8.17.10-linux-x86_64.tar.gz
```

---

## 15. Extract Logstash

```bash
tar -xzf logstash-8.17.10-linux-x86_64.tar.gz
```

Verify:

```bash
ls -lah
```

The installation should be:

```text
/mnt/vol_e/bigdata/logstash/logstash-8.17.10
```

Remove the archive:

```bash
rm logstash-8.17.10-linux-x86_64.tar.gz
```

---

## 16. Configure Logstash Environment Variables

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
# Logstash
export LOGSTASH_HOME=/mnt/vol_e/bigdata/logstash/logstash-8.17.10
export PATH=$LOGSTASH_HOME/bin:$PATH
```

Reload:

```bash
source ~/.bashrc
```

Verify:

```bash
echo $LOGSTASH_HOME
which logstash
```

Expected:

```text
/mnt/vol_e/bigdata/logstash/logstash-8.17.10
/mnt/vol_e/bigdata/logstash/logstash-8.17.10/bin/logstash
```

---

## 17. Verify Logstash

```bash
logstash --version
```

Expected:

```text
logstash 8.17.10
```

---

# Testing the ELK Pipeline

## 18. Create a Logstash Configuration

Create a configuration directory:

```bash
mkdir -p ~/logstash
```

Create the configuration file:

```bash
nano ~/logstash/students.conf
```

Add:

```text
input {
  stdin {
  }
}

filter {
  json {
    source => "message"
  }
}

output {
  elasticsearch {
    hosts => ["https://localhost:9200"]
    user => "elastic"
    password => "YOUR_ELASTIC_PASSWORD"
    ssl_certificate_authorities => ["${ELASTICSEARCH_HOME}/config/certs/http_ca.crt"]
    index => "students"
  }

  stdout {
    codec => rubydebug
  }
}
```

Replace:

```text
YOUR_ELASTIC_PASSWORD
```

with your Elasticsearch password.

> Do not commit this file if it contains the real password.

A better approach for a repository is to keep credentials in environment variables rather than hard-coding them.

---

# 19. Run Logstash

Run:

```bash
logstash -f ~/logstash/students.conf
```

Wait for Logstash to finish initializing.

---

## 20. Send Test Data

With Logstash waiting for input, enter:

```json
{"name":"Merna","course":"Big Data","department":"Computer Engineering","score":100}
```

Press Enter.

Logstash should display the processed event in the terminal.

The event is also sent to Elasticsearch.

---

# Elasticsearch Index

## 21. Check the Index

Open another terminal and run:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/_cat/indices?v
```

Look for:

```text
students
```

---

## 22. Search the Students Index

Run:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/students/_search?pretty
```

The inserted document should appear in the response.

---

# Elasticsearch Dev Tools

## 23. Open Dev Tools

In Kibana:

```text
Menu
  ↓
Dev Tools
  ↓
Console
```

Dev Tools allows Elasticsearch REST API requests to be executed directly from Kibana.

---

## 24. Create an Index

Elasticsearch 8 uses typeless mappings.

Use:

```http
PUT students
{
  "mappings": {
    "properties": {
      "name": {
        "type": "text"
      },
      "course": {
        "type": "keyword"
      },
      "department": {
        "type": "keyword"
      },
      "score": {
        "type": "integer"
      }
    }
  }
}
```

### Important

Do not use the old syntax:

```json
"mappings": {
  "_doc": {
    "properties": {}
  }
}
```

Elasticsearch 8 returns:

```text
The mapping definition cannot be nested under a type [_doc]
```

because mapping types were removed.

---

# 25. Insert a Student

In Dev Tools:

```http
POST students/_doc/1
{
  "name": "Merna",
  "course": "Big Data",
  "department": "Computer Engineering",
  "score": 100
}
```

---

## 26. Add More Students

Example:

```http
POST students/_doc/2
{
  "name": "Ahmed",
  "course": "Big Data",
  "department": "Computer Engineering",
  "score": 92
}
```

```http
POST students/_doc/3
{
  "name": "Mariam",
  "course": "Data Engineering",
  "department": "Computer Engineering",
  "score": 95
}
```

```http
POST students/_doc/4
{
  "name": "Omar",
  "course": "Data Engineering",
  "department": "Computer Engineering",
  "score": 88
}
```

```http
POST students/_doc/5
{
  "name": "Youssef",
  "course": "Database Systems",
  "department": "Computer Engineering",
  "score": 90
}
```

---

# Kibana Data View

## 27. Create a Data View

In Kibana:

```text
Stack Management
    ↓
Data Views
    ↓
Create data view
```

For the index pattern, enter:

```text
students*
```

Select the `students` index.

If a time field is not being used, choose:

```text
I don't want to use the time filter
```

Create the data view.

### Terminology

Older Kibana versions called this:

```text
Index Pattern
```

Kibana 8 uses:

```text
Data View
```

The pattern:

```text
students*
```

matches indices such as:

```text
students
students-2026
students-001
```

---

# Kibana Discover

## 28. Open Discover

Navigate to:

```text
Discover
```

Select:

```text
students*
```

The indexed student documents should appear.

You can inspect fields such as:

```text
name
course
department
score
```

---

# Kibana Visualizations

The following visualizations demonstrate basic Elasticsearch aggregation and Kibana visualization capabilities.

---

## 29. Visualization 1 — Students by Course

Create a visualization.

Choose:

```text
Vertical Bar
```

Title:

```text
Students per Course
```

Configure:

```text
Metric:
    Count

X-Axis:
    Terms

Field:
    course
```

Save as:

```text
Students by Course
```

This shows how many students belong to each course.

---

## 30. Visualization 2 — Students per Department

Create another visualization.

Choose:

```text
Pie
```

Title:

```text
Students per Department
```

Configure:

```text
Metric:
    Count

Bucket:
    Terms

Field:
    department
```

Save as:

```text
Department Distribution
```

---

## 31. Visualization 3 — Average Student Score

Create a visualization.

Choose:

```text
Metric
```

Title:

```text
Average Student Score
```

Configure:

```text
Metric:
    Average

Field:
    score
```

Save.

This displays the average score across the indexed students.

---

## 32. Visualization 4 — Average Score by Course

Create a visualization.

Choose:

```text
Data Table
```

Configure:

```text
Metric:
    Average

Field:
    score

Split Rows:
    Terms

Field:
    course
```

Save as:

```text
Average Score by Course
```

---

# Student Analytics Dashboard

## 33. Create the Dashboard

Navigate to:

```text
Dashboard
    ↓
Create dashboard
```

Add all four saved visualizations.

Arrange them approximately as:

```text
┌──────────────────────────────────────────────────────────────┐
│                    Average Student Score                     │
├────────────────────────────┬─────────────────────────────────┤
│                            │                                 │
│     Students by Course     │     Department Distribution     │
│                            │                                 │
├────────────────────────────┴─────────────────────────────────┤
│                                                              │
│                 Average Score by Course                      │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

Save as:

```text
Student Analytics Dashboard
```

---

# Running the ELK Stack

The three components are separate processes.

For a manual development setup, use three terminals.

### Terminal 1 — Elasticsearch

```bash
elasticsearch
```

### Terminal 2 — Kibana

```bash
kibana
```

### Terminal 3 — Logstash

```bash
logstash -f ~/logstash/students.conf
```

Then access Kibana through:

```text
http://localhost:5601
```

---

# Convenience Aliases

Starting the stack manually requires several commands, so aliases can make development easier.

Edit:

```bash
nano ~/.bashrc
```

Add:

```bash
# Elasticsearch
alias elastic-start='elasticsearch'

# Kibana
alias kibana-start='kibana'

# Logstash
alias logstash-start='logstash -f ~/logstash/students.conf'
```

Reload:

```bash
source ~/.bashrc
```

Then:

```bash
elastic-start
```

```bash
kibana-start
```

```bash
logstash-start
```

> Each command is still a foreground process, so it normally needs its own terminal.

---

# Stopping the ELK Stack

If the services are running in foreground terminals:

```text
Ctrl + C
```

can be used to stop each service.

If a process continues running in the background, identify it with:

```bash
ps aux | grep elasticsearch
```

```bash
ps aux | grep kibana
```

```bash
ps aux | grep logstash
```

Then stop the relevant process if necessary.

---

# Troubleshooting

## Elasticsearch does not start

Check:

```bash
echo $ELASTICSEARCH_HOME
```

and:

```bash
elasticsearch --version
```

Check whether port `9200` is already being used:

```bash
ss -ltnp | grep 9200
```

---

## Elasticsearch is running but curl fails

Use the CA certificate:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200
```

Do not simply use:

```bash
curl http://localhost:9200
```

because Elasticsearch 8 enables HTTPS and authentication by default.

---

## Elasticsearch says JAVA_HOME is being ignored

You may see:

```text
warning: ignoring JAVA_HOME=...; using bundled JDK
```

This is normal for Elasticsearch distributions that include their own JDK.

---

## Kibana enrollment token expired

Generate a new token:

```bash
$ELASTICSEARCH_HOME/bin/elasticsearch-create-enrollment-token -s kibana
```

Use the newly generated token.

---

## Kibana cannot connect to Elasticsearch

Make sure Elasticsearch is running first:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200
```

Then restart Kibana.

---

## Logstash cannot connect to Elasticsearch

Check:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200
```

Verify that:

* Elasticsearch is running
* the username is correct
* the password is correct
* the CA certificate path is correct
* Logstash is configured to use `https://localhost:9200`

---

## Elasticsearch mapping error involving `_doc`

If you see:

```text
The mapping definition cannot be nested under a type [_doc]
```

you are using an old typed mapping.

Use:

```http
PUT students
{
  "mappings": {
    "properties": {
      "name": {
        "type": "text"
      }
    }
  }
}
```

instead of:

```json
"mappings": {
  "_doc": {
    "properties": {}
  }
}
```

---

## Kibana does not show the index

Check Elasticsearch:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/_cat/indices?v
```

If `students` does not appear, the documents have not been indexed successfully.

If the index exists, create a Kibana Data View:

```text
students*
```

---

## Data View cannot find fields

Make sure documents actually exist:

```http
GET students/_search
```

If the index was created before fields were added, refresh the Data View in Kibana.

---

# Useful Elasticsearch Commands

## List indices

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/_cat/indices?v
```

## Search all students

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/students/_search?pretty
```

## Count students

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/students/_count?pretty
```

## Get a specific document

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/students/_doc/1?pretty
```

## Delete the test index

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  -X DELETE \
  https://localhost:9200/students
```

> This permanently deletes the index and its documents. Use only for test data.

---

# Verification Checklist

Run:

```bash
elasticsearch --version
```

Expected:

```text
8.17.10
```

Run:

```bash
logstash --version
```

Expected:

```text
8.17.10
```

Check Elasticsearch:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200
```

Check cluster health:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/_cluster/health?pretty
```

Check indices:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/_cat/indices?v
```

Check students:

```bash
curl --cacert $ELASTICSEARCH_HOME/config/certs/http_ca.crt \
  -u elastic \
  https://localhost:9200/students/_search?pretty
```

Open Kibana:

```text
http://localhost:5601
```

Then verify:

* [ ] Elasticsearch is running
* [ ] Kibana is connected
* [ ] Logstash is running
* [ ] `students` index exists
* [ ] `students*` Data View exists
* [ ] Documents appear in Discover
* [ ] Students by Course visualization works
* [ ] Department Distribution visualization works
* [ ] Average Student Score visualization works
* [ ] Average Score by Course visualization works
* [ ] Student Analytics Dashboard is saved

---

# Final Architecture

The completed ELK setup is:

```text
                  ┌──────────────┐
                  │ Data Source  │
                  └──────┬───────┘
                         │
                         ▼
                  ┌──────────────┐
                  │  Logstash    │
                  │              │
                  │ Input        │
                  │ Filter       │
                  │ Output       │
                  └──────┬───────┘
                         │
                         ▼
                ┌──────────────────┐
                │  Elasticsearch   │
                │                  │
                │ students index   │
                └────────┬─────────┘
                         │
                         ▼
                  ┌──────────────┐
                  │    Kibana    │
                  │              │
                  │ Discover     │
                  │ Visualize    │
                  │ Dashboards   │
                  └──────────────┘
```

The main responsibilities are:

| Component     | Responsibility                           |
| ------------- | ---------------------------------------- |
| Logstash      | Ingest and transform data                |
| Elasticsearch | Store, index, search, and aggregate data |
| Kibana        | Explore and visualize the data           |

Together they provide a complete pipeline for collecting, indexing, searching, and visualizing data.
