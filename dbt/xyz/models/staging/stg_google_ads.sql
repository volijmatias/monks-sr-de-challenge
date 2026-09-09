with source as (

    select *
    from {{ source('raw', 'google_ads') }}

),

renamed as (

    select
        date,
        campaign_id,
        campaign_name,
        placement_id,
        account_id,
        account_name,
        {{ normalize_country('country') }} as country,
        clicks,
        impressions,
        spend,
        batch_window_start,
        batch_window_end,
        batch_id,
        ingested_at,
        'google_ads' as platform
    from source

)

select *
from renamed
