
  
    

    create or replace table `data-talk-clubs`.`eu_emissions_project_intermediate`.`int_dim_capitals`
      
    
    

    OPTIONS()
    as (
      

-- Reference the capitals seed file
SELECT
    geo_code,
    Capital AS capital_city,
    Country AS country_name
FROM `data-talk-clubs`.`eu_emissions_project`.`capitals`
    );
  