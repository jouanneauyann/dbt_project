{% macro generate_alias_name(custom_alias_name=none, node=none) -%}

    {%- if custom_alias_name -%}

        {{ custom_alias_name | trim }}

    {%- elif node.version -%}

        {{ return(node.name ~ "_v" ~ (node.version | replace(".", "_"))) }}

    {%- elif node.name and 'model' in node.resource_type -%}

        {{ node.name.split("__")[-1] }}

    {%- else -%}

        {{ node.name }}

    {%- endif -%}

{%- endmacro %}