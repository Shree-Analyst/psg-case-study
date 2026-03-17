--Join profiles to populations using LEFT JOIN on fan_id to preserve profiles that do not exist in populations.

WITH profiles AS (
    SELECT *
    FROM {{ ref('int_profiles') }}
),

profiles_pops AS (
    SELECT *
    FROM profiles
    LEFT JOIN {{ ref('int_populations') }}
      USING (fan_id)
)

-- LEFT JOIN this table to ticketing_23_24 using fan_id to preserve profiles data & add ticketing data.

SELECT *
FROM profiles_pops
LEFT JOIN {{ ref('int_ticketing_23_24') }}
  USING (fan_id)

-- INNER JOIN profiles_pops to ticketing_24_25 using fan_id to only preserve profiles that have ticketing data.
-- Use UNION ALL to stack tables vertically.

UNION ALL
SELECT *
FROM profiles_pops
INNER JOIN {{ ref('int_ticketing_24_25_2') }}
  USING (fan_id)