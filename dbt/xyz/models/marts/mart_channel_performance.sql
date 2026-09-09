{{ config(
    materialized='table'
) }}

with channel_metrics as (

    select
        date,
        platform,
        country,

        sum(impressions) as impressions,
        sum(clicks) as clicks,
        sum(spend) as spend,
        sum(sessions) as sessions,
        sum(conversions) as conversions,
        sum(purchases) as purchases,
        sum(revenue) as revenue

    from {{ ref('fct_campaigns') }}

    group by
        date,
        platform,
        country

)

select
    date,
    platform,
    country,

    impressions,
    clicks,
    spend,
    sessions,
    conversions,
    purchases,
    revenue,

    case
        when impressions > 0
        then clicks::numeric / impressions
        else 0
    end as ctr,

    case
        when clicks > 0
        then spend / clicks
        else 0
    end as cpc,

    case
        when sessions > 0
        then conversions::numeric / sessions
        else 0
    end as conversion_rate,

    case
        when spend > 0
        then revenue / spend
        else 0
    end as roas

from channel_metrics
