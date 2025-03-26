{{ config(
    materialized='table',
    partition_by={
        "field": "year",
        "data_type": "int64",
        "range": {
            "start": 2018,
            "end": 2025,
            "interval": 1
        }
    },
    cluster_by=["country_name", "unit"]
) }}

WITH emissions_data AS (
    SELECT *
    FROM {{ ref('int_emissions_cleaned') }}
),

capitals_data AS (
    SELECT *
    FROM {{ ref('int_dim_capitals') }}
),

-- Join emissions data with capitals information
emissions_with_location AS (
    SELECT
        e.*,
        c.capital_city,
        c.country_name
    FROM emissions_data e
    LEFT JOIN capitals_data c
        ON e.geo_code = c.geo_code
),

-- Calculate yearly averages by location
yearly_averages AS (
    SELECT
        capital_city,
        country_name,
        geo_code,
        EXTRACT(YEAR FROM measurement_date) AS year,
        airpol,
        unit,
        AVG(measurement_value) AS avg_value,
        MIN(measurement_value) AS min_value,
        MAX(measurement_value) AS max_value,
        SUM(measurement_value) AS total_emissions,
        COUNT(*) AS measurement_count
    FROM emissions_with_location
    GROUP BY capital_city, country_name, geo_code, EXTRACT(YEAR FROM measurement_date), airpol, unit
),

-- Calculate year-over-year changes
yoy_changes AS (
    SELECT
        current_year.*,
        current_year.avg_value - prev_year.avg_value AS absolute_change,
        CASE 
            WHEN prev_year.avg_value = 0 OR prev_year.avg_value IS NULL THEN NULL
            ELSE (current_year.avg_value - prev_year.avg_value) / prev_year.avg_value * 100 
        END AS percentage_change
    FROM yearly_averages current_year
    LEFT JOIN yearly_averages prev_year
        ON current_year.geo_code = prev_year.geo_code
        AND current_year.year = prev_year.year + 1
        AND current_year.airpol = prev_year.airpol
        AND current_year.unit = prev_year.unit
),

-- Calculate country rankings by year
country_rankings AS (
    SELECT
        year,
        country_name,
        airpol,
        unit,
        avg_value,
        RANK() OVER(PARTITION BY year, airpol, unit ORDER BY avg_value) AS pollution_rank_asc,
        RANK() OVER(PARTITION BY year, airpol, unit ORDER BY avg_value DESC) AS pollution_rank_desc
    FROM yearly_averages
    WHERE country_name IS NOT NULL
)

-- Final analytical model
SELECT 
    y.capital_city,
    y.country_name,
    y.geo_code,
    y.year,
    y.airpol,
    y.unit,
    y.avg_value,
    y.min_value,
    y.max_value,
    y.total_emissions,
    y.measurement_count,
    y.absolute_change,
    y.percentage_change,
    -- Add trend indicators
    CASE
        WHEN y.percentage_change < -5 THEN 'Significant Decrease'
        WHEN y.percentage_change BETWEEN -5 AND -0.5 THEN 'Moderate Decrease'
        WHEN y.percentage_change BETWEEN -0.5 AND 0.5 THEN 'Stable'
        WHEN y.percentage_change BETWEEN 0.5 AND 5 THEN 'Moderate Increase'
        WHEN y.percentage_change > 5 THEN 'Significant Increase'
        ELSE 'Insufficient Data'
    END AS trend_category,
    -- Add country rankings
    r.pollution_rank_asc,
    r.pollution_rank_desc,
    -- Calculate percentile within year (lower percentile = lower pollution)
    PERCENT_RANK() OVER(PARTITION BY y.year, y.unit ORDER BY y.avg_value) AS pollution_percentile,
    -- Add a flag for capitals exceeding EU average (if EU27_2020 data exists)
    CASE
        WHEN eu.avg_value IS NULL THEN NULL
        WHEN y.avg_value > eu.avg_value THEN TRUE
        ELSE FALSE
    END AS exceeds_eu_average,
    -- Calculate how much above/below EU average (in percentage)
    CASE
        WHEN eu.avg_value IS NULL OR eu.avg_value = 0 THEN NULL
        ELSE (y.avg_value - eu.avg_value) / eu.avg_value * 100
    END AS percent_diff_from_eu_avg,
    CURRENT_TIMESTAMP() AS analysis_timestamp
FROM yoy_changes y
LEFT JOIN country_rankings r
    ON y.year = r.year
    AND y.country_name = r.country_name
    AND y.unit = r.unit
LEFT JOIN yearly_averages eu
    ON y.year = eu.year
    AND y.unit = eu.unit
    AND eu.geo_code = 'EU27_2020'
