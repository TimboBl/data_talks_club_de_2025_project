-- Create external table for nitrogen dioxide data
CREATE OR REPLACE EXTERNAL TABLE `data-talk-clubs.eu_emissions_project.nitrogen_dioxide_data`
OPTIONS (
  format = 'CSV',
  field_delimiter = '\t',
  skip_leading_rows = 1,
  uris = ['gs://data-talk-clubs-eu-emissions-dev/raw/nitrogen_dioxide_per_city.tsv'],
  allow_quoted_newlines = true,
  allow_jagged_rows = true,
  );
