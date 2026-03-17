WITH source AS (
    SELECT *
    FROM {{ source('core', 'ticketing_23_24') }}
),

renamed AS (
    SELECT Uuid AS fan_id,
      {{ adapter.quote("Pays _Union_")}} AS country,
      {{ adapter.quote("Compétition")}} AS competition,
      {{ adapter.quote("Séance")}} AS match,
      {{ adapter.quote("Date de Vente")}} AS purchased_on,
      {{ adapter.quote("N_Commande")}} AS order_id,
      Contingent AS contingent,
      {{ adapter.quote("Catégorie")}} AS seat_category,
      N_Billet AS ticket_number,
      {{ adapter.quote("Montant Primaire")}} AS primary_price,
      {{ adapter.quote("Montant Secondaire")}} AS secondary_price,
      {{ adapter.quote("Date Entrée")}} AS entry_timestamp
    FROM source
),

final AS (
    SELECT *,
      '23_24' AS season
    FROM renamed
)

SELECT *
FROM final