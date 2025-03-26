# EU Emissions Project - DBT Environment

This directory contains a Python virtual environment with dbt-core and dbt-bigquery installed for the EU Emissions data project.

## Environment Details

- Python version: 3.11
- dbt-core version: 1.9.3
- dbt-bigquery version: 1.9.1

## Using the Virtual Environment

### Activating the Environment

To activate the virtual environment, run the following command from the `src` directory:

```bash
source venv/bin/activate
```

Your command prompt should change to indicate that the virtual environment is active.

### Verifying dbt Installation

To verify that dbt is installed correctly, run:

```bash
dbt --version
```

This should display the installed versions of dbt-core and dbt-bigquery.

### Using dbt

Once the environment is activated, you can use dbt commands directly:

```bash
dbt init    # Initialize a new dbt project
dbt run     # Run your dbt models
dbt test    # Test your dbt models
```

### Deactivating the Environment

When you're done working with dbt, you can deactivate the virtual environment by running:

```bash
deactivate
```

## Project Integration

This dbt environment is set up to work with:

- GCS bucket: `data-talk-clubs-eu-emissions-dev`
- BigQuery dataset: `eu_emissions_project`

The dbt models will be used to create external tables and transformations for the EU emissions data that is ingested via Kestra workflows.

## Nitrogen Dioxide Data Pipeline

### Data Source

The project includes a pipeline for processing nitrogen dioxide emissions data from various European cities. The data is stored in TSV format in GCS at:

```
gs://data-talk-clubs-eu-emissions-dev/raw/nitrogen_dioxide_per_city.tsv
```

### dbt Models

The following dbt models have been created for the nitrogen dioxide data:

1. **Staging Model** (`models/staging/stg_emissions_data.sql`):
   - Creates a view that reads from the external table
   - Parses the combined metadata field (frequency, pollutant, unit, geo code)
   - Extracts all monthly measurements from 2018-01 to 2025-02

2. **Intermediate Model** (`models/intermediate/int_emissions_unpivoted.sql`):
   - Unpivots the monthly measurements into a more usable format
   - Creates a proper date field from the time period strings
   - Filters out null measurements

3. **Marts Model** (`models/marts/emissions_analysis.sql`):
   - Provides yearly averages by city and pollutant
   - Calculates year-over-year changes
   - Categorizes trends (significant decrease, moderate decrease, stable, etc.)

### Setup Requirements

Before running the dbt models, ensure:

1. The external table is created in BigQuery pointing to the GCS file
2. The service account has appropriate permissions to read from GCS and create/modify tables in BigQuery

### Running the Models

To run all models in the correct order:

```bash
dbt run
```

To run a specific model:

```bash
dbt run --select stg_emissions_data
