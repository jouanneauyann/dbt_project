{{
    config(
        materialized='table',
        transient=false,
        tags=["ogirys"]
    )
}}

SELECT 
    JSON_EXTRACT_PATH_TEXT(stay::string, 'id')::INTEGER AS modalite_id_sejour,
    M.id as id_modalite,
    begin,
    end,
    date_entree,
    date_sortie,
    S.id as sejour_id_sejour,
    GREATEST(S.LOADING_DATE, M.LOADING_DATE) AS LOADING_DATE
FROM {{ref('ogirys__modalites')}} M
INNER JOIN {{ref('ogirys__sejours')}} S ON modalite_id_sejour = S.id

