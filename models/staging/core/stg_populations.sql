WITH source AS (
    SELECT *
    FROM {{ source('core', 'populations') }}
),

renamed AS (
    SELECT `Uuid` AS fan_id,
      Population AS subscription_category,
      {{ adapter.quote("Max_ Date d'activation")}} AS start_date,
      {{ adapter.quote("Max_ Date de désactivation")}} AS end_date
    FROM source
),

final AS (
    SELECT *
    FROM renamed
)

SELECT *
FROM final