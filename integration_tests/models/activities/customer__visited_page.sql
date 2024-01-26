{% set keys = dbt_activity_schema.cluster_keys(stream='customer_stream') %}
{% if target.name == 'bigquery' %}
    {% set cluster_keys = keys.cluster_by %}
    {% set partition_keys = keys.partition_by %}
{# TODO: remove snowflake-specific implementation once localstack bugs are fixed #}
{% elif target.name == 'snowflake' %}
    {% set cluster_keys = none %}
    {% set partition_keys = none %}
{% else %}
    {% set cluster_keys = keys %}
    {% set partition_keys = '' %}
{% endif %}

{{ config(
    cluster_by=cluster_keys,
    partition_by=partition_keys,
    data_types={
        'referrer_url': dbt.type_string(),
    },
    stream='customer_stream'
)}}

with base as (
    select *
    from {{ ref('visited_page') }}
)
{{ dbt_activity_schema.build_activity('base', null_columns=['anonymous_customer_id','revenue_impact', 'link'])}}
