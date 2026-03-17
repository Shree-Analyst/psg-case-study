WITH source AS (
    SELECT *
    FROM {{ ref('stg_populations') }}
),

-- Select ABO & STE subscription categories & fan_id

sub_type AS (
    SELECT fan_id,
      subscription_category AS sub_type_1
    FROM {{ ref('stg_populations') }}
    WHERE subscription_category IN ('ABO', 'STE')
),

-- Add column to indicate fan status by joining source to sub_type

pop_type AS (
    SELECT *
    FROM source
    LEFT JOIN sub_type
      USING (fan_id)
),

-- Exclude ABO & STE from subscription_category

sub_cat_excluded AS (
    SELECT *
    FROM pop_type
    WHERE subscription_category NOT IN ('ABO', 'STE')
),

-- Augment sub_type_1 to include hospitality, premium (myparis, myfamily).

augmented AS (
    SELECT *,
      CASE WHEN subscription_category IN ('MYPARIS', 'MYFAMILY') THEN 'premium'
        WHEN subscription_category IN ('HOSPITALITES') THEN 'hospitality'
        ELSE sub_type_1
        END AS subscription_type
    FROM sub_cat_excluded
),

-- Replace ABO & STE with appropriate categories.

final AS (
    SELECT fan_id,
      subscription_category,
      start_date,
      end_date,
      CASE WHEN subscription_type = 'ABO' THEN 'individuel'
        WHEN subscription_type = 'STE' THEN 'corporate'
        ELSE subscription_type
        END AS subscription_type
    FROM augmented
)

SELECT *
FROM final