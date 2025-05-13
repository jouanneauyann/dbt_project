-- Table créé dans Snowflake
-- # tags=["ogirys"] permet de relancer lors d'un dbt run -s tag:ogirys tous les models contenant ogirys 

{{
    config(
        materialized='table',
        transient=false,
        tags=["ogirys"]
    )
}}
-- pre_hook: création de la table de landing via dbt_project.yaml
-- post_hook: suppression de la table de landing via dbt_project.yaml


SELECT id as SURROGATE_KEY,
       CURRENT_TIMESTAMP() as LOADING_DATE,
* FROM {{this.schema}}.{{this.name}}__landing
