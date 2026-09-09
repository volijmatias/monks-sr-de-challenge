select
    date,
    platform,
    country,
    count(*) as row_count
from {{ ref('mart_channel_performance') }}
group by
    date,
    platform,
    country
having count(*) > 1
