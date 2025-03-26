# TSV Data Pipeline for EU Emissions Project

## Overview

This document explains how to use the `tsv_data_pipeline.yml` workflow to process TSV.GZ files and load them into BigQuery as external tables.

## Workflow Features

- Downloads compressed TSV files from provided URLs
- Decompresses the files from TSV.GZ to TSV format
- Uploads the decompressed files to Google Cloud Storage
- Creates BigQuery external tables pointing to the TSV files
- Organizes data in GCS using the filename as folder structure
- Creates a combined view of all external tables

## How to Use

### Running the Workflow

1. Access the Kestra UI at http://localhost:8080
2. Navigate to the `eu.emissions` namespace
3. Find the `tsv_data_pipeline` workflow
4. Click "Execute"
5. Provide a list of URLs to TSV.GZ files in the `dataUrls` input parameter

Example input:
```json
{
  "dataUrls": [
    "https://example.com/data/emissions_2020.tsv.gz",
    "https://example.com/data/emissions_2021.tsv.gz",
    "https://example.com/data/emissions_2022.tsv.gz"
  ]
}
```

### Customizing the Workflow

#### Schema Definition

You'll need to modify the `create_external_table` task to match your actual data schema. The current schema is a placeholder with basic fields:

```sql
CREATE OR REPLACE EXTERNAL TABLE `data-talk-clubs.eu_emissions_project.{{ extract_filename.folderName }}` (
  country STRING,
  year INT64,
  emissions FLOAT64,
  -- Add more fields as needed
)
```

#### Combined View

The `create_combined_view` task creates a view that combines data from all external tables. You'll need to customize this query based on your actual tables and schema:

```sql
CREATE OR REPLACE VIEW `data-talk-clubs.eu_emissions_project.emissions_combined_view` AS
-- This is a placeholder query that you'll need to customize
SELECT * FROM `data-talk-clubs.eu_emissions_project.emissions_data`
-- Add UNION ALL statements for each of your external tables
;
```

## Workflow Process

1. **Extract Filename**: Extracts the filename and folder name from the URL
2. **Download File**: Downloads the TSV.GZ file from the provided URL
3. **Decompress File**: Converts the TSV.GZ file to TSV format
4. **Upload to GCS**: Uploads the TSV file to Google Cloud Storage
5. **Create External Table**: Creates a BigQuery external table pointing to the TSV file
6. **Create Combined View**: Creates a view that combines data from all external tables

## Scheduling

The workflow is scheduled to run daily at midnight. You can modify the schedule by changing the `cron` expression in the trigger configuration.
