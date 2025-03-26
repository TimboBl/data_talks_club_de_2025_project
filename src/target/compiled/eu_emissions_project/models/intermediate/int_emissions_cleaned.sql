

WITH emissions_data AS (
    SELECT *
    FROM `data-talk-clubs`.`eu_emissions_project_staging`.`stg_emissions_data`
)

SELECT 
    airpol,
    unit,
    geo_code,
    date_label,
    measurement_date,
    IF(measurement_value = 0.0, NULL, measurement_value) AS measurement_value
FROM emissions_data