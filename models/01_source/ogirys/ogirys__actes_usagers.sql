-- Table créé dans Snowflake
-- # tags=["ogirys"] permet de relancer lors d'un dbt run -s tag:ogirys tous les models contenant ogirys 

{% set table_name = this.name.split("__")[-1] %}

{{
    config(
        materialized='incremental',
        incremental_strategy="delete+insert",
        unique_key= 'PARTITION_KEY',
        transient=false,
        tags=["ogirys"], 
        on_schema_change='append_new_columns'
    )
}}
-- pre_hook: création de la table de landing via dbt_project.yaml
-- post_hook: suppression de la table de landing via dbt_project.yaml

SELECT id as SURROGATE_KEY,
       CONCAT_WS('|',date(debut)::STRING,structure::STRING) as PARTITION_KEY,
       CURRENT_TIMESTAMP() as LOADING_DATE,
* FROM {{this.schema}}.{{table_name}}__landing
