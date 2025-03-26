# Evidence Visualization Project

## Prerequisites

```bash
cd reports/
npm install
npm run dev
```
This will install all required dependencies and also start the dev server for you to check out locally. 
In order to view data, that was ingested using DBT and kestra, you will have to connect your BigQuery instance with the relevant tables to evidence. 
This can be done in the UI of evidence at `localhost:3000`. 
Once you have done that, and the configuration is correct, you may run `npm run sources`. 

Sources you will need to run the dashboard locally: 

##### Emissions by month
```sql 
select * from `<your_project_id>.<your_dataset>.emissions_analysis_monthly`;
```

##### Emissions by year
```sql 
select * from `<your_project_id>.<your_dataset>.emissions_analysis`;
```

