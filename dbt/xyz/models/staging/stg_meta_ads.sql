with source as (

    select *
    from {{ source('raw', 'meta_ads') }}

),

renamed as (

    select
        date,
        campaign_id,
        campaign_name,
        ad_location,
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
        'meta_ads' as platform
    from source

)

select *
from renamed
