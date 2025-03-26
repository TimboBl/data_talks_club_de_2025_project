# EU Emissions Project - DBT Environment

This directory contains a Python virtual environment with dbt-core and dbt-bigquery installed for the EU Emissions data project.

## Environment Details

- Python version: 3.11
- dbt-core version: 1.9.3
- dbt-bigquery version: 1.9.1

## Using the Virtual Environment

### Creating the Virtual Environment

To create the virtual environment, run the following command from the `src` directory:

```bash
python3 -m venv venv
```

### Activating the Environment

To activate the virtual environment, run the following command from the `src` directory:

```bash
source venv/bin/activate
pip install -r requirements.txt
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
   - Unpivots the monthly measurements from 2018-01 to 2025-02 into a long format
   - Creates a proper date field from the time period strings

2. **Intermediate Model** (`models/intermediate/int_emissions_cleaned.sql`):
   - Cleans the data from the staging model
   - Handles null values and data type conversions
   - Partitions data by measurement date for improved query performance

3. **Dimension Model** (`models/intermediate/int_dim_capitals.sql`):
   - Provides mapping between geographic codes and capital cities/countries
   - Used for enriching the emissions data with location information

4. **Seed File** (`seeds/capitals.csv`):
   - Contains mapping data for European capital cities
   - Maps geo_codes to capital city names and countries
   - Used as a dimension table for location enrichment
   - Loaded using `dbt seed` command

5. **Marts Models**:
   - **Yearly Analysis** (`models/marts/emissions_analysis.sql`):
     - Provides yearly averages, minimums, maximums, and totals by city and pollutant
     - Calculates year-over-year changes
     - Includes country rankings and comparisons to EU averages
     - Categorizes trends (significant decrease, moderate decrease, stable, etc.)
   
   - **Monthly Analysis** (`models/marts/emissions_analysis_monthly.sql`):
     - Similar to the yearly analysis but at a monthly granularity
     - Provides month-over-month trend analysis
     - Includes monthly rankings and comparisons to EU monthly averages

### Setup Requirements

Before running the dbt models, ensure:

1. The external table is created in BigQuery pointing to the GCS file. Use `create_external_table.sql` to create the table.
2. The service account has appropriate permissions to read from GCS and create/modify tables in BigQuery

### Running the Models

To run all models in the correct order:

```bash
dbt seed --full-refresh
dbt run
```

To run a specific model:

```bash
dbt run --select stg_emissions_data

dbt run --select int_emissions_cleaned

dbt run --select int_dim_capitals

dbt run --select emissions_analysis

dbt run --select emissions_analysis_monthly
```
