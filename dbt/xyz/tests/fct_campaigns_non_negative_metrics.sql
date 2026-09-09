select *
from {{ ref('fct_campaigns') }}
where impressions < 0
   or clicks < 0
   or spend < 0
   or sessions < 0
   or conversions < 0
   or purchases < 0
   or revenue < 0
