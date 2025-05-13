-- Create a json file format in a schema name
-- @param: this.schema, this.name
{% macro ingestion_json_ogirys() %}
    CREATE OR REPLACE FILE FORMAT {{ this.schema }}.json_file_format 
    TYPE = 'JSON' STRIP_OUTER_ARRAY = TRUE;

    CREATE OR REPLACE TRANSIENT TABLE {{ this.schema }}.{{ this.name }}__landing AS 
    SELECT value AS clean_json  
    FROM @{{ this.schema }}.INGESTION_STAGE/last_ingestion/{{ this.name }}/ 
    (FILE_FORMAT => '{{ this.schema }}.json_file_format'), 
    LATERAL FLATTEN(input => $1:data);

    COPY INTO @{{ this.schema }}.INGESTION_STAGE/last_ingestion/{{ this.name }}__cleaned/ 
    FROM (SELECT * FROM {{ this.schema }}.{{ this.name }}__landing) 
    FILE_FORMAT = (TYPE = JSON, COMPRESSION = NONE) 
    OVERWRITE = TRUE;

    CREATE OR REPLACE TRANSIENT TABLE {{ this.schema }}.{{ this.name }}__landing 
    USING TEMPLATE (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
    FROM TABLE(INFER_SCHEMA(LOCATION=>'@{{ this.schema }}.INGESTION_STAGE/last_ingestion/{{ this.name }}__cleaned/',
    FILE_FORMAT=>'{{ this.schema }}.json_file_format')));

    COPY INTO {{ this.schema }}.{{ this.name }}__landing 
    FROM @{{ this.schema }}.INGESTION_STAGE/last_ingestion/{{ this.name }}__cleaned/ 
    FILE_FORMAT = (FORMAT_NAME= '{{ this.schema }}.json_file_format') 
    MATCH_BY_COLUMN_NAME=CASE_INSENSITIVE;

    rm @{{ this.schema }}.INGESTION_STAGE/last_ingestion/{{ this.name }}__cleaned;
{% endmacro %}
