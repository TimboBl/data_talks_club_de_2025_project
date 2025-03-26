{{ config(
    materialized='table'
) }}

-- Reference the capitals seed file
SELECT
    geo_code,
    Capital AS capital_city,
    Country AS country_name
FROM {{ ref('capitals') }}
