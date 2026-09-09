{{ config(
    materialized='table'
) }}

select
    campaign_id,
    campaign_name,
    platform,
    country,
    window_start::date as date,

    sum(impressions) as impressions,
    sum(clicks) as clicks,
    sum(spend) as spend,
    sum(sessions) as sessions,
    sum(conversions) as conversions,
    sum(purchases) as purchases,
    sum(revenue) as revenue

from {{ ref('int_campaign_performance_6h') }}

group by
    campaign_id,
    campaign_name,
    platform,
    country,
    window_start::date
