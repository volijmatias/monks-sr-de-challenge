select *
from {{ ref('mart_channel_performance') }}
where ctr < 0
   or ctr > 1
   or cpc < 0
   or conversion_rate < 0
   or roas < 0
