{% macro normalize_country(column_name) %}

    case
        when lower({{ column_name }}) in ('us', 'united states')
            then 'US'
        else upper({{ column_name }})
    end

{% endmacro %}
