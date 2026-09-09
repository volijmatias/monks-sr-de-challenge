with source as (

    select *
    from {{ source('raw', 'google_analytics_events') }}

),

renamed as (

    select
        user_id,
        session_id,
        event_timestamp,
        event_name,
        event_params,
        nullif(campaign_id, '') as campaign_id,
        stream_name,
        page_url,
        {{ normalize_country('country') }} as country,
        is_conversion,
        ingested_at
    from source

)

select *
from renamed
