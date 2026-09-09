with ads as (

    select
        campaign_id,
        campaign_name,
        platform,
        country,
        batch_window_start as window_start,
        batch_window_end as window_end,
        clicks,
        impressions,
        spend
    from {{ ref('stg_google_ads') }}

    union all

    select
        campaign_id,
        campaign_name,
        platform,
        country,
        batch_window_start as window_start,
        batch_window_end as window_end,
        clicks,
        impressions,
        spend
    from {{ ref('stg_meta_ads') }}

),

session_campaign as (

    select
        session_id,
        campaign_id,
        country
    from (
        select
            session_id,
            campaign_id,
            country,
            row_number() over (
                partition by session_id
                order by event_timestamp
            ) as rn
        from {{ ref('stg_ga4_events') }}
        where campaign_id is not null
    ) s
    where rn = 1

),

ga4_events as (

    select
        e.session_id,
        e.event_timestamp,
        e.event_name,
        e.is_conversion,
        e.event_params,
        s.campaign_id,
        e.country
    from {{ ref('stg_ga4_events') }} e
    inner join session_campaign s
        on e.session_id = s.session_id

),

ga4_metrics as (

    select
        campaign_id,
        country,

        date_trunc(
            'hour',
            event_timestamp
        )
        - (
            extract(
                hour from event_timestamp
            )::integer % 6
        ) * interval '1 hour' as window_start,

        count(distinct session_id) as sessions,

        count(*) filter (
            where is_conversion
        ) as conversions,

        count(*) filter (
            where event_name = 'purchase'
        ) as purchases,

        coalesce(
            sum(
                case
                    when event_name = 'purchase'
                    then (event_params ->> 'value')::numeric
                    else 0
                end
            ),
            0
        ) as revenue

    from ga4_events

    group by
        campaign_id,
        country,
        date_trunc('hour', event_timestamp)
        - (
            extract(
                hour from event_timestamp
            )::integer % 6
        ) * interval '1 hour'

),

final as (

    select
        a.campaign_id,
        a.campaign_name,
        a.platform,
        a.country,
        a.window_start,
        a.window_end,

        a.impressions,
        a.clicks,
        a.spend,

        coalesce(g.sessions, 0) as sessions,
        coalesce(g.conversions, 0) as conversions,
        coalesce(g.purchases, 0) as purchases,
        coalesce(g.revenue, 0) as revenue

    from ads a

    left join ga4_metrics g
        on a.campaign_id = g.campaign_id
        and a.country = g.country
        and a.window_start = g.window_start

)

select *
from final
