WITH source AS (
    SELECT *
    FROM {{ ref('stg_profiles') }}
),

augmented AS (
    SELECT fan_id,
      gender,
      CASE WHEN gender = 'MME' THEN 'F'
        WHEN gender = 'Mme' THEN 'F'
        ELSE gender
        END AS gender_aug,
      country_code,
      birthday,
      consent_partners,
      CASE WHEN consent_partners = 'Oui'
        THEN 1
        ELSE 0
        END AS consent_partners_aug,
      consent_psg,
      CASE WHEN consent_psg = 'Oui'
        THEN 1
        ELSE 0
        END AS consent_psg_aug,
      DATE_DIFF('2026-03-01', birthday, YEAR) AS age
    FROM source
),

final AS (
    SELECT fan_id,
      gender_aug AS gender,
      country_code,
      birthday,
      consent_partners_aug AS consent_partners,
      consent_psg_aug AS consent_psg,
      age
    FROM augmented
)

SELECT *
FROM final