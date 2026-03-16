WITH source AS (
    SELECT *
    FROM {{ source('core', 'profiles') }}
),

renamed AS (
    SELECT Uuid AS fan_id,
      {{ adapter.quote("Civilité")}} AS gender,
      `Code pays_zone géographique` AS country_code,
      `Date de naissance` AS birthday,
      `Optin : Partners` AS consent_partners,
      `Optin : PSG` AS consent_psg
    FROM source
),

final AS (
    SELECT *
    FROM renamed
)

SELECT *
FROM final