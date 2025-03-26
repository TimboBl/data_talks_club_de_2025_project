

  create or replace view `data-talk-clubs`.`eu_emissions_project_staging`.`stg_emissions_data`
  OPTIONS()
  as 

WITH source AS (
    SELECT 
        *
    FROM `data-talk-clubs`.`eu_emissions_project`.`nitrogen_dioxide_data`
),

-- First, prepare the data by converting columns to the right format for unpivoting
preprocessed AS (
    SELECT
        freq_airpol_unit_geo_TIME_PERIOD AS metadata,
        -- All other columns are measurement data columns
        *
    FROM source
),

-- Use UNPIVOT to transform the wide format to long format
unpivoted AS (
    SELECT
        metadata,
        col_name AS date_column,
        CAST(col_value AS STRING) AS measurement_value
    FROM preprocessed
    UNPIVOT(
        col_value FOR col_name IN (
            _2018_01_, _2018_02_, _2018_03_, _2018_04_, _2018_05_, _2018_06_,
            _2018_07_, _2018_08_, _2018_09_, _2018_10_, _2018_11_, _2018_12_,
            _2019_01_, _2019_02_, _2019_03_, _2019_04_, _2019_05_, _2019_06_,
            _2019_07_, _2019_08_, _2019_09_, _2019_10_, _2019_11_, _2019_12_,
            _2020_01_, _2020_02_, _2020_03_, _2020_04_, _2020_05_, _2020_06_,
            _2020_07_, _2020_08_, _2020_09_, _2020_10_, _2020_11_, _2020_12_,
            _2021_01_, _2021_02_, _2021_03_, _2021_04_, _2021_05_, _2021_06_,
            _2021_07_, _2021_08_, _2021_09_, _2021_10_, _2021_11_, _2021_12_,
            _2022_01_, _2022_02_, _2022_03_, _2022_04_, _2022_05_, _2022_06_,
            _2022_07_, _2022_08_, _2022_09_, _2022_10_, _2022_11_, _2022_12_,
            _2023_01_, _2023_02_, _2023_03_, _2023_04_, _2023_05_, _2023_06_,
            _2023_07_, _2023_08_, _2023_09_, _2023_10_, _2023_11_, _2023_12_,
            _2024_01_, _2024_02_, _2024_03_, _2024_04_, _2024_05_, _2024_06_,
            _2024_07_, _2024_08_, _2024_09_, _2024_10_, _2024_11_, _2024_12_,
            _2025_01_, _2025_02_
        )
    )
    -- Filter out zero values that represent missing data
    -- WHERE measurement_value != '0.0'
),

-- Process the date and value after unpivoting
processed_measurements AS (
    SELECT
        metadata,
        -- Clean up column name by removing underscores
        REPLACE(date_column, '_', '') AS clean_date_column,
        -- Keep measurement value as string for now
        measurement_value,
        -- Extract month and year from column name and create a proper date
        DATE(CONCAT(
            SUBSTR(REPLACE(date_column, '_', ''), 1, 4), '-',
            SUBSTR(REPLACE(date_column, '_', ''), 5, 2), '-01'
        )) AS measurement_date,
        -- Create a readable date label (e.g., 'Jan 2018')
        CONCAT(
            FORMAT_DATE('%b', DATE(CONCAT(
                SUBSTR(REPLACE(date_column, '_', ''), 1, 4), '-',
                SUBSTR(REPLACE(date_column, '_', ''), 5, 2), '-01'
            ))),
            ' ',
            SUBSTR(REPLACE(date_column, '_', ''), 1, 4)
        ) AS date_label
    FROM unpivoted
),

metadata_extracted AS (
    SELECT
        -- Extract metadata components
        SPLIT(metadata, ',')[SAFE_OFFSET(0)] AS frequency,
        SPLIT(metadata, ',')[SAFE_OFFSET(1)] AS airpol,
        SPLIT(metadata, ',')[SAFE_OFFSET(2)] AS unit,
        SPLIT(metadata, ',')[SAFE_OFFSET(3)] AS geo_code,
        date_label,
        measurement_date,
        -- Convert measurement value to FLOAT64 here, after unpivoting
        -- Use TRIM to remove any potential whitespace and explicit comparison
        CASE 
            WHEN TRIM(measurement_value) = '0.0' THEN NULL
            ELSE SAFE_CAST(measurement_value AS FLOAT64)
        END AS measurement_value,
        CURRENT_TIMESTAMP() AS load_timestamp
    FROM processed_measurements
),

final AS (

SELECT
    ROW_NUMBER() OVER() AS id,
    frequency,
    airpol,
    unit,
    geo_code,
    date_label,
    measurement_date,
    measurement_value,
    load_timestamp
FROM metadata_extracted
ORDER BY geo_code, measurement_date
)

select * from final;

