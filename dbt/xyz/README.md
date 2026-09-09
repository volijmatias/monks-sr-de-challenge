# XYZ — dbt Analytics Layer

This directory contains the dbt implementation of the analytical transformation layer defined in Deliverable A of the XYZ Senior Data Engineer Challenge.

The project uses the PostgreSQL raw tables provided by the challenge lab as its ingestion contract and implements the transformation logic using dbt staging, intermediate and mart models.

## Architecture

```text
RAW — PostgreSQL
│
├── raw.google_analytics_events
├── raw.google_ads
└── raw.meta_ads
        │
        ▼
STAGING
│
├── stg_ga4_events
├── stg_google_ads
└── stg_meta_ads
        │
        ▼
INTERMEDIATE
│
└── int_campaign_performance_6h
        │
        ├───────────────┐
        ▼               ▼
MARTS
│
├── fct_campaigns
│      campaign × platform × country × day
│
└── mart_channel_performance
       platform × country × day
       + CTR / CPC / Conversion Rate / ROAS
```

The six-hour grain is preserved in the intermediate layer because it matches the Ads delivery cadence and provides a natural unit for window-level completeness and incremental processing. The business-facing marts are aggregated to daily grain.

## Models

### Staging

The staging models provide a source-specific, normalized representation of the raw tables:

* `stg_ga4_events`
* `stg_google_ads`
* `stg_meta_ads`

Country values are normalized across sources through the `normalize_country` macro. For example, `US` and `United States` are mapped to the common value `US`.

### Intermediate

`int_campaign_performance_6h` integrates Ads and GA4 data at:

```text
campaign × platform × country × 6-hour window
```

GA4 events are attributed using a first-touch campaign rule within each session: the earliest non-null campaign associated with the session is used to attribute the session's events.

The model calculates:

* impressions
* clicks
* spend
* sessions
* conversions
* purchases
* revenue

### Marts

#### `fct_campaigns`

Daily campaign-level fact table at:

```text
campaign × platform × country × day
```

This model aggregates the six-hour intermediate data into the business-facing daily grain.

#### `mart_channel_performance`

Daily channel-level performance mart at:

```text
platform × country × day
```

In addition to the base metrics, it calculates:

* CTR = clicks / impressions
* CPC = spend / clicks
* Conversion Rate = conversions / sessions
* ROAS = revenue / spend

`conversions` uses the `is_conversion` flag provided by the GA4 source, while `purchases` is kept as a separate metric based on purchase events.

## Data Quality

The project includes both schema-level and singular dbt tests.

Tests cover:

* source and model column validity
* not-null constraints
* accepted platform values
* campaign fact grain uniqueness
* channel mart grain uniqueness
* non-negative metrics
* KPI consistency and valid ranges

The current implementation passes all tests:

```text
PASS=42
WARN=0
ERROR=0
```

## Running the project

The challenge lab must be running and populated before executing dbt.

From this directory:

```bash
dbt debug
dbt run
dbt test
```

To rebuild the project from scratch:

```bash
dbt clean
dbt run
dbt test
```

The dbt project expects the PostgreSQL connection defined by the `xyz` profile in the user's dbt profiles configuration.

## Project Structure

```text
xyz/
├── dbt_project.yml
├── macros/
│   └── normalize_country.sql
├── models/
│   ├── staging/
│   │   ├── sources.yml
│   │   ├── schema.yml
│   │   ├── stg_ga4_events.sql
│   │   ├── stg_google_ads.sql
│   │   └── stg_meta_ads.sql
│   ├── intermediate/
│   │   └── int_campaign_performance_6h.sql
│   └── marts/
│       ├── schema.yml
│       ├── fct_campaigns.sql
│       └── mart_channel_performance.sql
└── tests/
    ├── fct_campaigns_unique_grain.sql
    ├── fct_campaigns_non_negative_metrics.sql
    ├── mart_channel_performance_unique_grain.sql
    └── mart_channel_performance_kpi_consistency.sql
```

## Design Note

Deliverable A defines the target cloud architecture and data contracts, while this dbt project implements the corresponding analytical transformation layer locally against the PostgreSQL ingestion layer supplied by the challenge.

The dbt project therefore does not reproduce the cloud infrastructure one-to-one. Instead, staging and intermediate models represent the transformation contracts, while the marts represent the production analytical layer.



:q
\q
