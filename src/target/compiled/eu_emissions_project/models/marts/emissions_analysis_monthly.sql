

WITH emissions_data AS (
    SELECT *
    FROM `data-talk-clubs`.`eu_emissions_project_intermediate`.`int_emissions_cleaned`
),

capitals_data AS (
    SELECT *
    FROM `data-talk-clubs`.`eu_emissions_project_intermediate`.`int_dim_capitals`
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

-- Monthly data is already available in the cleaned data
-- No need for additional aggregation by month
monthly_data AS (
    SELECT
        capital_city,
        country_name,
        geo_code,
        measurement_date,
        FORMAT_DATE('%Y-%m', measurement_date) AS year_month,
        EXTRACT(YEAR FROM measurement_date) AS year,
        EXTRACT(MONTH FROM measurement_date) AS month,
        airpol,
        unit,
        measurement_value
    FROM emissions_with_location
),

-- Calculate month-over-month changes
mom_changes AS (
    SELECT
        current_month.*,
        current_month.measurement_value - prev_month.measurement_value AS absolute_change,
        CASE 
            WHEN prev_month.measurement_value = 0 OR prev_month.measurement_value IS NULL THEN NULL
            ELSE (current_month.measurement_value - prev_month.measurement_value) / prev_month.measurement_value * 100 
        END AS percentage_change
    FROM monthly_data current_month
    LEFT JOIN monthly_data prev_month
        ON current_month.geo_code = prev_month.geo_code
        AND DATE_SUB(current_month.measurement_date, INTERVAL 1 MONTH) = prev_month.measurement_date
        AND current_month.airpol = prev_month.airpol
        AND current_month.unit = prev_month.unit
),

-- Calculate country rankings by month
country_rankings AS (
    SELECT
        year_month,
        country_name,
        airpol,
        unit,
        measurement_value,
        RANK() OVER(PARTITION BY year_month, airpol, unit ORDER BY measurement_value) AS pollution_rank_asc,
        RANK() OVER(PARTITION BY year_month, airpol, unit ORDER BY measurement_value DESC) AS pollution_rank_desc
    FROM monthly_data
    WHERE country_name IS NOT NULL
)

-- Final analytical model
SELECT 
    m.capital_city,
    m.country_name,
    m.geo_code,
    m.measurement_date,
    m.year,
    m.month,
    m.year_month,
    m.airpol,
    m.unit,
    m.measurement_value,
    m.absolute_change,
    m.percentage_change,
    -- Add trend indicators
    CASE
        WHEN m.percentage_change < -5 THEN 'Significant Decrease'
        WHEN m.percentage_change BETWEEN -5 AND -0.5 THEN 'Moderate Decrease'
        WHEN m.percentage_change BETWEEN -0.5 AND 0.5 THEN 'Stable'
        WHEN m.percentage_change BETWEEN 0.5 AND 5 THEN 'Moderate Increase'
        WHEN m.percentage_change > 5 THEN 'Significant Increase'
        ELSE 'Insufficient Data'
    END AS trend_category,
    -- Add country rankings
    r.pollution_rank_asc,
    r.pollution_rank_desc,
    -- Calculate percentile within month (lower percentile = lower pollution)
    PERCENT_RANK() OVER(PARTITION BY m.year_month, m.unit ORDER BY m.measurement_value) AS pollution_percentile,
    -- Add a flag for capitals exceeding EU average (if EU27_2020 data exists)
    CASE
        WHEN eu.measurement_value IS NULL THEN NULL
        WHEN m.measurement_value > eu.measurement_value THEN TRUE
        ELSE FALSE
    END AS exceeds_eu_average,
    -- Calculate how much above/below EU average (in percentage)
    CASE
        WHEN eu.measurement_value IS NULL OR eu.measurement_value = 0 THEN NULL
        ELSE (m.measurement_value - eu.measurement_value) / eu.measurement_value * 100
    END AS percent_diff_from_eu_avg,
    CURRENT_TIMESTAMP() AS analysis_timestamp
FROM mom_changes m
LEFT JOIN country_rankings r
    ON m.year_month = r.year_month
    AND m.country_name = r.country_name
    AND m.unit = r.unit
LEFT JOIN monthly_data eu
    ON m.year_month = eu.year_month
    AND m.unit = eu.unit
    AND eu.geo_code = 'EU27_2020'