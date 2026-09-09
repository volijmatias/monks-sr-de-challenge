select
    campaign_id,
    platform,
    country,
    date,
    count(*) as row_count
from {{ ref('fct_campaigns') }}
group by
    campaign_id,
    platform,
    country,
    date
having count(*) > 1
