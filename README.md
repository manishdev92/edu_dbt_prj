
# 📘 edu_dbt_prj

**Education Analytics Data Platform (dbt + Elementary + Redshift-Ready POC)**

----------

## 🚀 Overview

`edu_dbt_prj` is a production-style **education analytics data platform POC** built using:

-   **dbt** (transformations, testing, snapshots)
    
-   **Postgres (local) → Redshift-ready design**
    
-   **Elementary** (data observability + freshness monitoring)
    
-   **Docker**
    
-   **Automation via Makefile**
    
-   **CI-ready structure**
    

This project simulates a real-world **education business model** (similar to Colibri Group):

-   Students
    
-   Enrollments
    
-   Course activity
    
-   Course completion
    
-   Certifications
    
-   Payments
    

It produces business-ready marts:

-   📊 Student Lifecycle (prospect → enrolled → active → at-risk → completed → certified)
    
-   📈 Certification KPIs (pass rate by attempt, avg days to certification)
    
-   📜 Historical tracking via dbt Snapshots
    
-   🔍 Data freshness + quality observability via Elementary
    

----------

## 🏗 Architecture
<img width="1237" height="600" alt="image" src="https://github.com/user-attachments/assets/904dadf2-d955-4ee1-b700-1ef54652977f" />

### 🔹 POC (Local)

Python Generator
        ↓
Raw Schemas (raw_lms, raw_billing, raw_cert)
        ↓
dbt Staging (stg_stg)
        ↓
Fact + Mart Layer (stg_marts)
        ↓
Snapshots (snapshots schema)
        ↓
Elementary Observability (stg schema)` 

----------

### 🔹 Production Equivalent

POC Component

Production Equivalent

Python Loader

Fivetran Connectors

Postgres

Amazon Redshift

Makefile

Airflow / dbt Cloud Jobs

Local Freshness

Scheduled Freshness Checks

Local HTML Report

Slack / Teams Alerts + Report Artifacts

----------

# 📂 Repository Structure

edu_dbt_prj/
│
├── analytics/ # dbt project │   ├── models/
│   │   ├── staging/
│   │   ├── marts/
│   │   └── snapshots/
│   ├── tests/
│   └── dbt_project.yml
│
├── ingestion/ # Sample data generator + loader ├── warehouse/ddl/ # Raw schema DDL ├── scripts/ # Pipeline automation ├── docs/ # Demo walkthrough ├── edr_target/ # Elementary report output ├── docker-compose.yml
├── Makefile
└── requirements.txt

----------

# 🧠 Core Data Models

## 📊 fact_learning_activity_daily

Grain:

`student_id + course_id + activity_date` 

-   Incremental-ready
    
-   Merge strategy
    
-   Redshift dist/sort key compatible
    

----------

## 📈 mart_student_lifecycle_daily

Grain:

`student_id + as_of_date` 

Lifecycle stages:

-   prospect
    
-   enrolled
    
-   active
    
-   at_risk
    
-   completed
    
-   certified
    

Implements:

-   business rules
    
-   daily snapshot logic
    
-   incremental-ready design
    

----------

## 🎓 mart_certification_kpis

Provides:

-   Pass rate by attempt number
    
-   Avg days to certification
    
-   Certification-level metrics
    

----------

## 📜 snap_students (dbt Snapshot)

Implements:

-   Slowly Changing Dimension (Type 2)
    
-   Historical change tracking
    
-   `strategy='timestamp'`
    
-   `_ingested_at` as change detector
    

----------

# 🔍 Data Observability (Elementary)

Configured features:

-   ✅ dbt tests monitoring
    
-   ✅ Source freshness SLAs
    
-   ✅ Model execution metadata
    
-   ✅ HTML report generation
    

Generate report:

`edr report --project-dir analytics --profiles-dir ~/.dbt` 

Output:

`edr_target/elementary_report.html` 

----------

# ⚙️ Local Setup

## 1️⃣ Start Postgres

`make up` 

----------

## 2️⃣ Setup Python

`python3 -m venv .venv source .venv/bin/activate
pip install -r requirements.txt` 

----------

## 3️⃣ Configure dbt Profile

`mkdir -p ~/.dbt cp analytics/profiles.yml.example ~/.dbt/profiles.yml` 

Ensure port matches Docker config (default: 6543).

----------

## 4️⃣ Run Full Pipeline

`make pipeline` 

This runs:

1.  Generate sample data
    
2.  Load raw schemas
    
3.  dbt build
    
4.  dbt source freshness
    
5.  Elementary report
    

----------

# 🔄 CI/CD Ready

Includes:

-   Makefile automation
    
-   GitHub Actions compatible structure
    
-   dbt build + freshness checks
    
-   Redshift-ready incremental models
    

----------

# 🧩 Redshift Optimization Strategy

Prepared for production:

-   Incremental models with MERGE
    
-   Sort keys on date columns
    
-   Dist keys on student_id
    
-   Rolling window incremental loads
    
-   Schema sync on change
    
-   Freshness monitoring
    
-   Observability reporting
    

----------

# 🛠 Technologies Used

-   dbt (1.7)
    
-   Postgres (local warehouse)
    
-   Elementary (0.16)
    
-   Docker
    
-   Python 3.11
    
-   Makefile Automation
    

----------

# 📌 Notes

-   This is a POC for demonstration/interview purposes.
    
-   In production:
    
    -   Replace Python ingestion with Fivetran
        
    -   Use Redshift instead of Postgres
        
    -   Run dbt via scheduler (Airflow/dbt Cloud)
        
    -   Enable Slack/Teams alerts in Elementary
        

----------

# 👤 Author

Manish Tiwari  
Senior Data Engineer | Analytics Engineering | Data Platform Architecture
