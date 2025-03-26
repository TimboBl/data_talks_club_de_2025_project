{{ config(
    materialized='table',
    partition_by={
        "field": "measurement_date",
        "data_type": "date",
        "granularity": "month"
    },
    cluster_by=["geo_code"]
) }}

WITH emissions_data AS (
    SELECT *
    FROM {{ ref('stg_emissions_data') }}
)

SELECT 
    airpol,
    unit,
    geo_code,
    date_label,
    measurement_date,
    IF(measurement_value = 0.0, NULL, measurement_value) AS measurement_value
FROM emissions_data
