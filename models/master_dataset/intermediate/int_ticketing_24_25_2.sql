WITH source AS (
    SELECT *
    FROM {{ ref('stg_ticketing_24_25') }}
),

-- isolate match_date & match using date_trunc on event_timestamp column, filtering to non-null values.

matchday AS (
    SELECT DISTINCT match,
      CAST(DATE_TRUNC(entry_timestamp, DAY) AS DATE) AS match_date
    FROM source
    WHERE entry_timestamp IS NOT NULL
),

-- Join this table back to source using match column.

combined AS (
    SELECT *
    FROM source
    INNER JOIN matchday
      USING (match)
),

-- remove 'PARIS VS ' from match & save as opp; calculate date difference between match_date and purchased_on;
-- create 'is_noshow' column where if entry_timestamp is null, the supporter is a no-show.

cleaned AS (
    SELECT *,
      REPLACE(match, 'PARIS VS ', '') AS opp,
      DATE_DIFF(match_date, CAST(purchased_on AS DATE), DAY) AS lead_time,
      CASE WHEN entry_timestamp IS NULL THEN 1
        ELSE 0
        END AS is_noshow
    FROM combined
),

-- replace ' (CDF)' from opp and save as opponent.
-- Calculate Gross Spend as the maximum value of primary price & secondary price.
-- Denote whether a sale is primary or secondary using case when.

augmented AS (
    SELECT *,
      REPLACE (opp, ' (CDF)', '') AS opponent,
      CASE WHEN secondary_price > 0 THEN secondary_price
        ELSE primary_price
        END AS gross_spend,
      CASE WHEN secondary_price > 0 THEN 'secondary'
        WHEN (secondary_price = 0 OR secondary_price IS NULL)
          AND primary_price > 0 THEN 'primary'
        ELSE 'other'
        END AS sale_platform
    FROM cleaned
),

--  Select necessary columns

final AS (
    SELECT fan_id,
      country,
      competition,
      CAST(DATE_TRUNC(purchased_on, DAY) AS DATE) AS purchased_on,
      order_id,
      contingent,
      seat_category,
      ticket_number,
      primary_price,
      secondary_price,
      entry_timestamp,
      season,
      match_date,
      opponent,
      lead_time,
      is_noshow,
      gross_spend,
      sale_platform
    FROM augmented
)

SELECT *
FROM final