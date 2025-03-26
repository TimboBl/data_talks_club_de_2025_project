
  
    

    create or replace table `data-talk-clubs`.`eu_emissions_project_intermediate`.`int_emissions_cleaned`
      
    partition by date_trunc(measurement_date, month)
    cluster by geo_code

    OPTIONS()
    as (
      

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
    );
  