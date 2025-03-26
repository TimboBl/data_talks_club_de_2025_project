# EU Emissions Data Project

This repository contains infrastructure, data pipelines, and analysis tools for processing and analyzing EU emissions data, with a focus on nitrogen dioxide emissions across European cities.
The project was done during the DataTalks Zoomcamp for Data Engineering 2025. 

The Problem I wanted to solve was downloading some data from the European Union Data Repository ([Eurostat](https://ec.europa.eu/eurostat/data/database)) and processing it in BigQuery.
The Dataset I chose was [Nitrogen dioxide per city](https://ec.europa.eu/eurostat/data/database?dataset=env_air_no2).
The following paragraphs explain how this was done and also instruct how to reproduce the project.

## Project Overview

The project implements a complete data pipeline that:

1. **Extracts** emissions data from Eurostat in TSV.GZ format
2. **Loads** the data into Google Cloud Storage
3. **Transforms** the data using dbt models in BigQuery
4. **Analyzes** emissions trends across European cities

## Repository Structure

- [`/terraform`](./terraform/README.md) - Infrastructure as Code for GCP resources
- [`/kestra`](./kestra/README.md) - Data orchestration workflows
- [`/src`](./src/README.md) - dbt models and data transformation logic

## Getting Started

### Prerequisites

- Google Cloud Platform account with billing enabled
- Docker and Docker Compose
- Python 3.11+
- Terraform 1.0+
- Git

### Setup Steps

1. **Clone the repository**

```bash
git clone <repository-url>
cd project
```

2. **Set up GCP infrastructure**

Follow the instructions in the [Terraform README](./terraform/README.md) to provision the required GCP resources:

```bash
cd terraform
terraform init
terraform apply
```

3. **Configure and start Kestra**

Follow the instructions in the [Kestra README](./kestra/README.md) to set up the data orchestration service:

```bash
cd ../kestra
# Create service account and configure .env
docker-compose up -d
```

4. **Set up the dbt environment**

Follow the instructions in the [dbt README](./src/README.md) to set up the data transformation environment:

```bash
cd ../src
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

5. **Run the data pipeline**

- Trigger the Kestra workflow via the UI at http://localhost:8080
- Once data is loaded to GCS, create the external table and run dbt models:

```bash
cd ../src
dbt seed --full-refresh
dbt run
```

## Data Flow

1. **Data Ingestion** (Kestra)
   - Downloads TSV.GZ files from Eurostat
   - Converts to TSV format
   - Uploads to GCS bucket (`data-talk-clubs-eu-emissions-dev`)

2. **Data Transformation** (dbt)
   - Creates external tables in BigQuery from GCS files
   - Transforms wide-format data to long-format
   - Cleans and enriches data with location information
   - Creates analytical models for emissions analysis

3. **Data Analysis**
   - Yearly and monthly emissions analysis
   - Trend identification and city rankings
   - Comparison to EU averages

