# Kestra Orchestration for EU Emissions Project

This directory contains the configuration for Kestra, an open-source orchestration tool used to manage data workflows between Google Cloud Storage and BigQuery for the EU Emissions project.

## Setup Instructions

### Prerequisites

- Docker and Docker Compose installed
- Google Cloud SDK installed
- A GCP service account with permissions for:
  - BigQuery Data Editor
  - Storage Object Admin

### Configuration

1. Create a service account key file:

```bash
gcloud iam service-accounts create kestra-sa --display-name="Kestra Service Account"

gcloud projects add-iam-policy-binding data-talk-clubs \
    --member="serviceAccount:kestra-sa@data-talk-clubs.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"

gcloud projects add-iam-policy-binding data-talk-clubs \
    --member="serviceAccount:kestra-sa@data-talk-clubs.iam.gserviceaccount.com" \
    --role="roles/storage.objectAdmin"

gcloud iam service-accounts keys create service-account.json \
    --iam-account=kestra-sa@data-talk-clubs.iam.gserviceaccount.com
```

2. Create a `.env` file from the example:

```bash
cp .env.example .env
```

3. Start Kestra:

```bash
docker-compose up -d
```

4. Access the Kestra UI at http://localhost:8080

## Workflow Description

The sample workflow `eu_emissions_pipeline.yml` demonstrates a complete ETL process:

1. **Extract**: Downloads emissions data from a source
2. **Load**: Uploads the data to Google Cloud Storage
3. **Transform**: Loads the data into BigQuery and performs transformations

## Customizing Workflows

Workflows are defined in YAML format in the `flows` directory. You can modify the sample workflow or create new ones based on your specific requirements.

## Production Deployment

For production use, consider deploying Kestra on Google Kubernetes Engine (GKE) for better scalability and reliability.

## References

- [Kestra Documentation](https://kestra.io/docs)
- [Kestra GCP Plugins](https://kestra.io/plugins/plugin-gcp)
