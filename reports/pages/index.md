## Data Talk Clubs Data Engineering Zoomcamp Project 2025

This report details nitrogen dioxide emissions in the EU by capital city.
Below you can see the queries used as well as the resulting tables they produce. They match 1:1 with the marts in Google BigQuery. 

```sql emissions_by_year
  select *, CONCAT(capital_city, ' - ', country_name) as city_country
  from eu_emissions.emissions_by_year
```

```sql emissions_by_capital_and_month
select ANY_VALUE(capital_city) as capital_city, ANY_VALUE(country_name) as country_name, SUM(measurement_value) as total_emissions, year_month
from eu_emissions.emissions_by_month
group by capital_city, country_name, year_month
```
<br/>

### Emissions of Nitrogen Dioxide by European Capitals from 2018 - 2025

This chart shows the distribution of nitrogen dioxide emissions by capital city over the timerange of 2018 to 2025. In 2025 data ends in February.
<BarChart 
data={emissions_by_year}
x=year
y=total_emissions
series=city_country
xAxisLabels=true
title="Total Emissions by Capital City (NO2 mg/m3)"
/>
In this chart, are the polution values of nitrogen dioxide per capital city. Filtering can be done by selecting or deselecting capital cities from the top of the chart.
<LineChart 
data={emissions_by_capital_and_month} 
x=year_month 
y=total_emissions 
series=capital_city 
xAxisLabels=true
title="Total Emissions by Capital City (NO2 mg/m3)"
/>

This heatmap shows basically the same as the line chart above only in a different visualization. The values are provided in NO2 mg/m3.
<Heatmap data={emissions_by_year} x=year y=city_country value=total_emissions title="Total emissions by month over time"/>

<footer>
Made with evidence
</footer>



