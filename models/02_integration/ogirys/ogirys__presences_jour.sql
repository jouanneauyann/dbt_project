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

SELECT 
    CONCAT_WS('|',date::STRING,structure::STRING,benef::STRING) as SURROGATE_KEY,
    CONCAT_WS('|',date::STRING,structure::STRING) as PARTITION_KEY,
    structure, 
    benef, 
    date, 
    listagg(JSON_EXTRACT_PATH_TEXT(period::string, 'id'),'-') AS period_presences,
    listagg(state,'-') as state_presences
FROM {{ref('ogirys__presences')}}
WHERE 1=1
{% if is_incremental() %}
    AND PARTITION_KEY IN (
        SELECT 
            CONCAT_WS('|',date::STRING,structure::STRING) 
        FROM {{ref('ogirys__presences')}} 
        WHERE LOADING_DATE > CURRENT_DATE - 5
        )
{% endif %}

GROUP BY all
