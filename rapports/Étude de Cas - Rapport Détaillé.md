# Étude de Cas PSG - Rapport Détaillé

![PSG Logo](psg.png)

**Méthodologie Globale** : Après une synthèse des besoins et onboarding du dataset, les données ont été chargés vers BigQuery, transformés en dbt, et rechargé vers Tableau. Ensuite, une analyse exploratoire et la construction du tableau de bord est suivie par la synthétisation des insights dans ce rapporte détaillé. Ensuite, les recommandations ont été préparées et finalement, rapportées dans le sommaire exécutif.

## Méthodologie - Synthèse des Besoins

D'abord, les questions des parties prenantes suivantes ont été ciblées comme **questions globales à repondre** :
1. Qui sont les fans (prospects, abonnés, clients) de PSG en Asie et en Afrique ? Quel est leur profil démographique et géographique ?
2. Quels sont les pays à fort potentiel dans ces régions ?
3. Quels sont les comportements de consommation des fans Asiatiques et Africains en billetterie ?
4. Comment sont-ils segmentés les fans de PSG dans ces régions ?
5. Quels sont les segments de fans à fort potentiel ?

Les parties prenantes identifiées sont **Marketing, Sponsoring, Merchandising, et Billetterie**. Leurs but est à savoir quelles actions mener pour améliorer la stratégie d'engagement en Asie & en Afrique.

### Identification & Définition de Métriques & Dimensions

Ensuite, les métriques clées pour l'analyse sont définies et séparés en 3 rubriques :

#### Métriques de Comptage

- **Supporteur Count** : Nombre total de supporteurs dans la base de données.
- **Prospect Count** : Nombre total de supporteurs n'ayant acheté ni de produit digital ni de billet.
- **Abonné Count** : Nombre total de supporteurs ayant souscrit un abonnement prémium sans acheter un billet.
- **Client Count** : Nombre total de supporteurs ayant fait un achat en billetterie.
- **Billets Vendus** : Nombre total de billets vendus.

#### Métriques de Consommation

- **Dépenses Brutes** : Montant en € dépensé par des clients en billetterie.
- **Panier Moyen** : Montant en € dépensé par billet.
- **Dépenses Moyennes Par Utilisateur (ARPU)** : Total des montants dépensés en € par un client en billetterie, proxy pour Average Revenue per User (ARPU). Autrement dit, LTV Historique.
- **Lead Time Moyen** : Temps en jours entre date d'achat du billet et date de match.

#### Métriques de Proportions

- **Part des Dépenses du Marché Secondaire** : % des dépenses venant par le marché de revente.
- **Part des Billets du Marché Secondaire** : % de clients achetant leur billet au marché de revente.
- **Taux de Conversions Clients** : % de supporteurs qui sont devenus abonnées ou clients.
- **Taux d'Abandon** : % de clients avec un billet qui n'ont pas assisté au match.
- **Taux d'Opt-ins** : % de supporteurs ayant donnés leur consentement pour le marketing.
  - **Partenaire** : % de supporteurs ayant donnés leur consentement pour le marketing au partenaire du PSG.
  - **PSG** : % de supporteurs ayant donnés leur consentement pour le marketing directement au PSG.

#### Métriques Avancés

- **Uplift Potentiel Conversion** : Abonnés prémium et clients supplémentaires gagnés par des actions marketing.
- **Uplift Potentiel de Dépenses** : Dépenses supplémentaire en € dues aux actions marketing.

#### Notes

1. **Calcul de Revenue** : Il y a un montant primaire et un montant secondaire. Certaines colonnes ont les deux. Certaines ont que le montant secondaire. Le PSG ne perçoit qu'une marge (de 18 % selon Ticketplace) sur les ventes secondaires. Il existe aussi des montants primaires supérieurs aux montants secondaires (171 lignes). **Le but étant d'évaluer le pouvoir d'achat** des fans, et pas d'être précis d'un point de vue financière, il sera mieux de calculer une **'dépense brute'** par billet pour l'analyse.

    **Dépense Brute = montant secondaire si existe, montant primaire sinon.**
    Sans savoir le prix exacte du billet au marché primaire, une **vente au marché primaire peut avoir une valeur nette jusqu'à 5,5 fois plus qu'une vente au marché secondaire**.

2. **Prix Total Commande ou Prix par Billet** : il semble que certains colonnes pour des commandes VIP aux salons ont des prix primaires qui peuvent être le prix d'une commande de plusieurs billets. Par contraintes de temps et pour répondre aux buts d'analyse, il est **assumé qu'un prix primaire = le prix d'un billet**, À éclairer avec le BU Billetterie plus tard.

#### Dimensions

Ces dimensions sont utilisées pour répondre aux besoins de parties prenantes : catégories de supporteur (prospect, abonné, ou client), pays d'origine, continent, âge, civilité, saison, compétition, adversaire du match, catégorie de siège, plateforme de vente (marché primaire ou secondaire), et classement RFM des clients.

**Dimensions dépriorisées :**
- Abonnement souscrit - à part la 3e question, les parties prenantes cherchent à répondre aux besoins plus quantitatives que qualitatives. Avec seulement 228 abonnés au MyParis (< 0,1 %) dont 9 abonnés au stade et 5 abonnés hospitality (fortement probable d'être des clients VIP ou prémiums), cette dimension serait utile à analyser les comportements fines des clients VIPs et savoir qui cibler pour des actions exclusives sponsoring, pas pour savoir quels pays cibler pour convertir plus de clients.
- Contingent - cette dimension a plusieurs valeurs intéressantes mais elle nécessite un travail de compréhension avec le BU Billetterie pour comprendre ce qu'elles signifient avant de les analyser.

### Définition de Requêtes Data

En utilisant un framework SCAN (Stakeholder Goals - Columns & Coverage - Aggregates & Anomalies - Notable Segments), les questions globales sont granularisées en questions fines à répondre avec Tableau et Python. Par exemple :

| Panier | Question de Partie Prenante | Métriques | Dimensions | Granularisation des Questions |
| --- | --- | --- | --- | --- |
| Profil des fans | Qui sont les fans de PSG en Asie et en Afrique ? Quel est leur profil démographique et géographique ? | Supporteur Count, Prospect Count, Abonné Count, Client Count | Continent, Pays, Tranche d'Âge | Combien de supporteurs avons-nous en Asie et en Afrique ? Quel est leur réparition selon tranches d'âge et civilité ? De quels pays venont-ils ? |

[Le reste des questions sont disponibles ici](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Granularisation%20de%20Questions.pdf).

## Méthodologie - Préparation de Données

Pour intégrer des tests, standardiser le nettoyage, et des augmentations initiales, les 4 tables sont d'abord sauvegardés sous encoding utf-8 avec Python, et ensuite chargé vers BigQuery. Les transformations sont faites en dbt (ELT) pour créer un master dataset. [La documentation dbt avec le code SQL est disponible ici](https://shree-analyst.github.io/psg-case-study/index.html#!/overview).

**La méthodologie en bref :**
- Tests unique & not_null sur les clés primaires des tables sources profiles & ticketing.
- Changement des noms de colonnes au staging layer.
- Application du framework CLEAN pour conceptualiser, nettoyer, et augmenter les données de manière structurée en layer intermédiaire. [Problèmes](#log-de-problèmes) & [augmentations](#log-daugmentations) documentés ci-dessous.
- Master dataset crée comme combinaison horizontal des tables populations, profiles, et ticketing 23-24 et vertical du table ticketing 24-25. Cela crée des Uuid dupliqués dans la table qui seront fixé en Tableau dans les étapes de calculs en utilisant expressions LOD.
- Par exemple, certains supporteurs sont classé comme clients dans une saison et prospects dans une autre saison. Pour éviter le comptage double, il fallait scorer les supporteurs (3 si client, 2 si abonné, 1 si prospect) avec une expression FIXED. Une aggrégation MAX permettait de traduire ces scores en catégorie de supporteur.
- Ajout d'une source de données externes pour lier le code_pays avec le nom du pays, et ajouter une dimension de continent.

### Log de Problèmes

| Table | Colonne | Problème | Compte avec % | Possibilité de Résoudre (Y/N) | Résolution |
| --- | --- | --- | --- | --- | --- |
| Profiles | Civilité | Nulls | 181644 (68,69 %) | N | Ne rien faire pour le moment |
| Profiles | Civilité | MME / Mme pour supporteurs femmes | 11869 (4,49 %) | Y | Remplacer avec 'F' |
| Profiles | Date de Naissance | Nulls | 2790 (1,06 %) | N | Moins de 10 %, inclure dans l'analyse |
| Populations | Population | Mélange de statut (ABO/STE) avec abonnement | 9 (3,56 %) | Y | Ajouter statut en colonne |
| Ticketing 23-24 | Pays _Union | Nulls | 243 (2,17 %) | N | Ne rien faire pour le moment |
| Ticketing 24-25 | Pays _Union | Nulls | 243 (0,65 %) | N | Ne rien faire pour le moment |

### Log d'Augmentations

| Table | Colonne Ajouté | Data Type | Description |
| --- | --- | --- | --- |
| Profiles | Âge | Integer | Âge du supporteur le 2026-03-01 |
| Population | Type d'abonné | String | Catégorisation d'abonné selon Prémium (MyParis / MyFamily), Stade - Individuel, Stade - Corporate, et Hospitality |
| Ticketing 23-24 | Match_Date | Date | Date du match |
| Ticketing 23-24 | opponent | String | Adversaire du match |
| Ticketing 23-24 | Lead_Time | Integer | Durée en jours d'achat du billet avant le match |
| Ticketing 23-24 | Is_noshow | Boolean | 1 si le client n'est pas venu au match, 0 s'il est venu |
| Ticketing 23-24 | gross_spend | Float | Montant en € dépensé pour le billet |
| Ticketing 23-24 | sale_platform | String | Plateforme de vente : primaire, secondaire, ou autre si billet avait pas de montant sur les deux |
| Ticketing 24-25 | Match_Date | Date | Date du match |
| Ticketing 24-25 | opponent | String | Adversaire du match |
| Ticketing 24-25 | Lead_Time | Integer | Durée en jours d'achat du billet avant le match |
| Ticketing 24-25 | Is_noshow | Boolean | 1 si le client n'est pas venu au match, 0 s'il est venu |
| Ticketing 24-25 | gross_spend | Float | Montant en € dépensé pour le billet |
| Ticketing 24-25 | sale_platform | String | Plateforme de vente : primaire, secondaire, ou autre si billet avait pas de montant sur les deux |

## Méthodologie - Analyse de Données

Les questions précises identifiées en requêtes data sont adressées principalement avec Tableau. Plusieurs calculs sont faits en utilisant des expressions. Les métriques sont segmentés par des dimensions en utilisant une combinaison de tables pivots et graphiques.

Python est utilisé si nécessaire, surtout pandas, numpy, matplotlib, seaborn, et scipy.stats. [Les notebooks sont disponibles ici](https://github.com/Shree-Analyst/psg-case-study/tree/main/notebooks).

### Contruction du Tableau de Bord

[Lien vers Tableau de Bord](https://public.tableau.com/app/profile/shreeraj.salunke/viz/PSGMarketingPerformanceDashboard/PerfDashboard#1)

Prenant en compte **le niveau intermédiaire des parties prenantes** et leurs buts (savoir qui cibler pour des actions marketing, suivi des KPIs), le tableau de bord contiendra un **mix de graphiques et de tables rapportant des chiffres brutes**.

Les métriques suivantes seront affichés en **haut de page** :
- Dépenses Brutes
- Part du Marché Secondaire
- Billets Vendus
- ARPU
- Lead Time
- Taux d'Abandon
- Panier Moyen

**Les visualisations suivantes sont priorisées :**
- Une table pour les pays en Asie avec le nombre de supporteurs, taux de conversion clients, et taux d'opt-ins PSG et Partenaires.
- Un Bar Graph coupé par adversaire permettant de suivre les dépenses brutes et le découpage primaire-secondaire en Asie.
- Une table pour les pays en Afrique avec le nombre de supporteurs, taux de conversion clients, et taux d'opt-ins PSG et Partenaires.
- Un Bar Graph coupé par adversaire permettant de suivre les dépenses brutes et le découpage primaire-secondaire en Afrique.
- Un Combo Graph coupé par catégorie de siège pour suivre les dépenses brutes par siège, le panier moyen, et le nombre de supporteurs.
- Un funnel pour voir les taux d'Opt-ins PSG, le nombre de clients, et le nombre d'abonnés.

Les filtres suivantes sont utilisés :
- Compétition
- Saison
- Opt-in Status (PSG, partenaires, ou les deux)
- Âge
- Pays
- Type de Supporteur (prospect, client, ou abonné)
- Continent (ne s'applique pas aux tables et Bar Graph d'Asie et d'Afrique)

Ces choix, vont **permettre aux parties prenantes** de suivre les KPIs et segmenter les supporteurs de manière efficace et effective, pour **répondre aux question « qui cibler pour des actions marketing ? »**.

## Analyses Exploratoires - Insights Contextuels

### Statistiques Descriptives

| Statistique | Compte | Pourcentage |
| --- | --- | --- |
| **Nombre de supporteurs** | **264,4k** | |
| Prospects | 252k | 95,3 % |
| Clients | 12,3k | 4,6 % |
| Abonnés | 96 | 0,04 % |
| **Billets Vendus** | **27k** | |
| Part du Marché Secondaire | 19,8k | 73,4 % |
| Taux d'Opt-in PSG | 164k | 62,2 % |
| Taux d'Opt-in Partenaires | 146k | 55,5 % |
| **Dépenses Brutes** | **14,37M €** | 100 % |
| Part du Marché Secondaire | 6,17 M € | 42,9 % |
| Panier Moyen | 532,2 € | |
| Dépenses Moyennes par Client | 1,17k € | |
| **Lead Time Moyen** | **30,29 jours** | |
| Abandons | 2,6k | 9,6 % |

La réparition **hommes-femmes est de 85,7 % - 14,3 %**. Avec plus de 80k réponses, on peut estimer que cette proportion reflète la réalité. Par contre, **plus de 68 % de supporteurs n'avaient pas répondu** à cette question. Donc, on **ne peut pas recommander d'utiliser la civilité d'un supporteur pour du ciblage personnalisé**.

**Âge Moyen de nos supporteurs : Moyenne = 32,3 ; Médiane = 30**. Présence d'outliers (+90 ans ou -16 ans) montrent que 658 supporteurs (< 0,3 %) ont probablement donné des âges fausses.

**Fourche de panier moyen : Moyenne = 532 € ; Médiane = 123 € ; Min = 5 € ; Max = 168k €**.

![Graphique avec distribution de lead time](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Distribution%20de%20Lead%20Time.png)

**Lead Time moyen : Moyenne = 30 jours ; Médiane = 14 jours ; Min = 0 jours ; Max = 445 jours**. Cela montre que la plupart de supporteurs Asiatiques & Africains achètent leurs billets dans les 2 semaines avant le match.

### 2 Fois Plus de Supporteurs en Asie qu'en Afrique

![image montrant réparition de supporteurs en Asie et Afrique](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Réparition%20de%20Pays.png "Réparition Pays")

Nous avons **176k supporteurs en Asie et 88k supporteurs en Afrique**. En prenant en compte la population, nous avons **37 supporteurs par million d'habitants en Asie et 60 supporteurs par million** d'habitants en Afrique. Cela veut dire que le PSG est supporté davantage par le public en Afrique qu'en Asie.

Il y a quasiment **12 fois plus de clients en Asie qu'en Afrique**. Cela reflète également dans un taux de clients par million plus élevé (0,8 - Afrique ; 2,6 - Asie) signalant probablement un marché sous-exploité en Afrique, un meilleur pouvoir d'achat de manière générale en Asie, ou bien une combinaison des deux.

#### Profil Supporteurs

**En Afrique, pour chaque supporteur femme, il y 20 hommes alors qu'en Asie, il y en a 5**. Cette contraste peut servir à adapter les stratégies de communication dans ces continents. Cette disparité se présente également dans la réparition clients.

**L'ensemble des fans Africains sont un peu plus jeunes** (âge médiane - 28 ans) que les fans Asiatiques (age médiane - 31 ans). Par ailleurs, **les clients Asiatiques sont plus jeunes (âge médiane - 34 ans) que les fans Africains (âge médiane - 40 ans)**, ce qu'est pareil pour des abonnés (36 ans - Asie ; 45 ans - Afrique).

Il reste **86k prospects en Afrique et 165k en Asie**.

#### Top Pays en Asie

![Top pays Asie](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Top%20Pays%20Asie.png)

La Corée du Sud, avec 58k supporteurs est en 1e place, devant l'Inde avec 37k et le Japon avec 16k. **La Corée du Sud (7,6k) est bien devant le Japon (1,6k) et le Chine (703) en nombre de clients**. L'âge médiane se differe également selon pays : les supporteurs venant d'Inde, de Bangladesh, et l'Afghanistan sont généralement plus jeunes (26 ans) alors que ceux venant de **Chine, Corée du Sud, Japon, et Singapour sont plus âgés (33-36 ans)**.

#### Top Pays en Afrique

![Top pays Afrique](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Top%20Pays%20Afrique.png)

Les top 3 en nombre de supporteurs en Afrique sont La Nigérie (12k), Le Maroc (11,6k), et l'Afrique du Sud (10,6k). Par ailleurs, **le Maroc (327), L'Afrique du Sud (129), et l'Algérie sont devants (109) en nombre de clients**.

Dans les pays tels que la Nigérie, l'Afrique du Sud, le Sénégal, le Côte d'Ivoire, et le Ghana, **les supporteurs sont jeunes, avec une age médiane de 26 ans**. Par contre, **les clients dans les top 3 pays Africains sont plus âgés : 41 ans pour le Maroc et l'Afrique du Sud, 36 ans pour l'Algérie**. Le cas de l'Afrique du Sud est intéressant : la grande majorité des supporteurs sont jeunes alors que la majorité des clients sont plus âgés. Cela montre que **l'offre billetterie n'est probablement pas attractif aux jeunes supporteurs Africains**.

Les taux de conversions sont également faibles, avec seulement **1 client pour 100 supporteurs** en Afrique, montrant probablement que l'ensemble des offres ne sont pas ciblés au public Africain.

## Insights Directionnels & Actionnables

### 8 Pays Contien 60 % de nos Prospects

![Scatterplot top 8](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Scatterplot%20Top%208.png)

**154k prospects** sont présents en seulement 8 pays : Corée du Sud, Inde, Japon, Chine, Nigérie, Maroc, Afrique du Sud, et Arménie. **La Corée du Sud lui-même compte 20 % des prospects**.

Il y a des différences importantes en potentiel d'activation par le PSG et par nos sponsors. Certains pays tel que le **Japon (42 % PSG, 28 % Partenaires) ont des audiences qui hésitent à recevoir des communications marketing**, alors que d'autes tel que la **Nigérie (81 % PSG, 86 % Partenaires) adorent les recevoir**. Certains ont des taux d'Opt-In assez différents pour PSG et Partenaires, tels que le **Maroc (68 % PSG, 32 % Partenaires), et l'Algérie (73 % PSG, 26 % Partenaires)**.

Lors du ciblage, l'implication pour est claire : **des campagnes localisées** ciblées à leurs audiences peuvent **convertir plus de clients qu'une stratégie globale**.

#### Calcul d'Uplift Potentiel en Conversions

Les audiences sont segmentés de manière suivantes selon pays :
- Certains - déjà clients ou abonnés avec opt-in PSG.
- Pesuadables - prospects avec opt-in PSG.
- Cause Perdus - prospects sans opt-in PSG.
- Ne pas déranger - déjà clients ou abonnés sans opt-in PSG.

Note - les « Certains » seront segmenté eux-mêmes plus tard pour Uplifter les dépenses.

Selon [High Block](https://www.highblock.pro/blog/the-club-revenue-formula-how-football-clubs-turn-fan-data-into-growth), **une campagne bien ciblée peut convertir des prospects en clients à un taux de 9 %**, quasiment double que le nôtre (4,6 %). **Assumons un taux d'amélioration plus modeste de 30 %** au lieu de 100 %.

Donc, pour la population ciblée :
- Taux de conversion nouveau = 1,3 * taux de conversion actuel
- Uplift Potentiel = taux de conversion nouveau - taux de conversion actuel.

**Méthodologie :** Un test statistique (Chi-Squared) a été d'abord mené pour valider les différences entre le taux de conversion en pays. **Il est significatif à 95 %, qui permet de faire confiance aux différences entre pays en taux de conversion et émettre une hypothèse que les taux de conversions suivront les taux historiques**. Les données sont préparés en Tableau chargé vers Python.

### 15 Pays Cibler Pour Ajouter 1400 Clients Supplémentaires

![Uplift Pays](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Uplift%20Conversions.png)

On peut identifier **47k prospects en 15 pays** à cibler pour des actions marketing pour donner 1,4k clients de billetterie ou abonnés supplémentaires.

Parmi ces clients supplémentaires, **1096 viendront du Corée du Sud** avec un uplift de 4 %, **183 de la Chine, et 77 du Japon**. Intéressemment, on peut ajouter **29 clients au Géorgie** avec du ciblage au seulement 966 prospects.

Les autres pays concernés sont **Singapour, Thaïlande, Kazakhsthan, Maurice, Ouzbekistan, Cambodge, Corée du Nord, Kyrgyzstan, Libye, Mongolie, et Djibouti**.

#### Pas d'Uplift Billetterie dans d'Autres Pays

Le ciblage dans les autres pays auront au moins un client déjà converti ne donne pas de clients supplémentaires en billetterie, ce qui **n'est pas surprenant parce que ces pays avaient des taux de conversion plus faibles**. Par ailleurs, il reste **plus de 110k prospects** qui nous ont donné leur consentement dans ces pays. Ça **peut intéresser les BUs Merchandising & Marketing**.

### Comportements Billetterie : Situations Contrastantes en Asie et en Afrique

![Bar-point](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Bar-Point%20Asia-Africa.png)

**Un client typique venant d'Asie dépense 320 € alors qu'un client typique venant d'Afrique au stade dépense 2,3k €**. Les choix des clients montrent la présence des segments vastement différents dans les deux continents : **un segment modeste qui achète beaucoup en Asie, et un segment super-prémium qui achète peu en Afrique**.

Les **Asiatiques** ont achetés **24k billets** parmi lesquels 18k venait (75 %) du marché secondaire. Cela a rapporté **7,72 M €** en dépenses brutes, **69 % desquels venait du marché secondaire**. Le **ARPU d'un supporteur Asiatique est 680 €** et il achète son billet 15 jours avant le match en moyenne. Par contre, **9,5 % de fans avec un billet ne viennent pas au match**.

Les **Africains** ont achetés **2,9k billets** parmi lesquels 1,6k (55 %) venait du marché secondaire. Cela a rapporté **6,65 M €** en dépenses brutes, avec **seulement 12 % venant du marché secondaire**. Le **ARPU d'un supporteur Africain est 7k €** et il achète son billet 9 jours avant le match. Par contre, **10,71 % de fans avec un billet ne viennent pas au match**.

Les disparités entre le lead time médiane montrent qu'**un supporteur Asiatique (15 jours) planifierait son voyage pour assister au match du PSG, alors qu'un supporteur Africain (9 jours) déciderait de réserver son billet après planifier son trajet**. Pourtant, le lead time moyenne en Afrique étant beaucoup plus élevé (48 jours), il existe probablement une partie des supporteurs qui réservent leurs billets bien avant le match.

#### 8 Pays Conduisant la Plupart des Dépenses Brutes

![Différences Table Asie-Afrique](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Africa-Asia%20Table.png)

**8 pays conduisent la quasi-totalité de nos dépenses**. La Guinée étant le pays leader en dépenses surprend, car elle compte seulement 7 clients.
- On peut voir que les ARPUs (plus de 20 fois) et les paniers moyens (plus de 10 fois) sont beaucoup plus supérieurs pour les clients **Africains (Panier Moyen 3,7K € ; ARPU 14,5K €)** que les clients **Asiatiques (Panier Moyen 300 € ; ARPU 620 €)**.
- Bien qu'il y a très peu de clients en Guinée et au Benin, **le Maroc et le Côte d'Ivoire comptent plus de 400 clients avec des paniers moyen et ARPU élevés, qui suffit pour valider ces différences entre le marché**.

#### Plupart des Dépenses Apportées par le Marché Secondaire

La plupart des billets sont achetés au marché secondaire. Pourtant, **le marché primaire reste plus lucratif pour le PSG** grâce aux dépenses plus élevés, surtout en Afrique où seulement 9 % des dépenses viennent du marché secondaire.
- Les supporteurs de haute valeurs sont repartis pourtant différemment selon pays : Au Bénin, la quasi-totalité des dépenses viennent du marché secondaire avec un panier moyen élevé de 11,5K €.
  - Au Guinée et au Côte d'Ivoire, la quasi-totalité des dépenses viennent du marché primaire.
- Par contraste en Asie, les supporteurs Coréens et Indiens dépensent au marché secondaire alors que les **clients Japonais et Chinois dépenses davantage au marché primaires (60 à 65 %)**.

### Comportementes Billetterie : Préférences des Matchs

Les top 3 adversaires meneurs de dépenses étaient **Borussia Dortmund (2,9M €), Marseille (1,4M €), et Milan (0,8M €)**. Les top 3 adversaires **meneurs de clients étaient Brest (1k), Rennes (711), et Reims (681)**. Cela ne surprend pas, car les matchs « chocs » ont beaucoup plus de demande que les matchs standards du Ligue 1.

![Préférences Asiatiques](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Matchs%20Asie.png)

Intéressemment, il y avait eu de gros dépenses au match contre Le Havre en saison 2023-24 par les fans Asiatiques (650K €), la plupart qui venait du marché primaire. Cela va au contraire de la tendance du marché de prioriser les matchs « chocs » en LDC : Borussia Dortmund, Manchester City, Liverpool, et Arsenal.

![Préférences Africains](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Matchs%20Afrique.png)

Les supporteurs Africains priorisent des adversaires continentaux ou français (Borussia Dortmund, Marseille, Milan, Lorient, Barcelone) et les plateformes de ventes directes, qui reflète leur pouvoir d'achat.

**Les affrontements contre les équipes anglais générait une partie majeur de dépenses au marché secondaire, peu importe le continent**.

### Implication des Différences en Comportement Billetterie

Ces différences montrent la nécessité des stratégies de ciblage personnalisées au chaque continent. Les buts du ciblage doivent être également différents par continent :
- **En Asie, le focus doit être de convertir plus de prospects en clients ou de leur proposer des offres merchandising**, due à un pouvoir d'achat des clients moins élevé.
- **En Afrique, le focus doit être de fidéliser les clients et maximiser leurs dépenses**, potentiellement leur transformer en abonnés, due à un pouvoir d'achat des clients plus élevé.

#### Calcul d'Uplift Potentiel Dépenses & ARPU

Les clients sont **d'abord segmentés avec des scores RFM**. Un score Fréquence classique divisant les fréquences en quartiles ne suffit pas, car 75 % de clients ont passé qu'une seule commande. Donc, le score **fréquence est divisé en 4 catégories suivantes selon le nombre de commandes**, (pas le nombre de billets) :
- Acheteurs uniques = 1
- Acheteurs doubles = 2
- Acheteurs fréquents (3 à 5 achats) = 3
- Acheteurs réguliers (> 5 achats) = 4

**La récence et la valeur monétaire sont coupés en quartiles**.

Les clients sont ensuite divisés en 4 catégories suivantes :
- Certains - Fréquence 4, R & M > 3 avec opt-in PSG
- **Persuadables - RFM 313, 414, 323, 424, ou fréquence 3 avec opt-in PSG**
- Causes perdus - Fréquence 1 ou 2 sans opt-in PSG
- Ne pas déranger - Tous les restes sans opt-in PSG.

Les clients sont **divisés de manière similaire selon leur statut d'opt-in partenaires pour isoler les clients avec un pouvoir d'achat élevé**.

Les données sont préparés en Python grâce aux fonctions cut et qcut en pandas. Le table préparé est rechargé vers Tableau et lié avec le master dataset en utilisant fan_id (Uuid).

Si le ciblage peut améliorer les dépenses de 10 %, on peut calculer le Uplift en dépenses de manière suivante :
- Dépenses nouvelles = 1,1 * Dépenses actuelles
- ARPU nouveau = Dépenses nouvelles / Clients en Population
- Uplift Potentiel (Dépenses) = dépenses nouvelles - dépenses actuelles
- Uplift Potentiel (ARPU) = ARPU nouveau - ARPU actuel.

Ces calculations seront fait sur Tableau.

### ~90 Clients Fréquents Persuadables par PSG Apportent 1,6M € en Dépenses

![Uplift PSG](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Uplift%20Spend%20PSG.png)

Ce sont des clients qui les clients qui achètent fréquemment des billets avec un montant brut élevé, signalant un **pouvoir d'achat élevé et une affinité pour la marque, surtout pour aller au stade**.

Ce sont identifiés comme des cibles de haute valeur pour des actions marketing & billetterie. Ils ont achetés leurs derniers billets entre 0 et 537 jours avant le dernier match dans la BDD (2025-05-17). Ils font **entre 3 et 5 commandes** et rapportent en moyenne **18K € par client avec des variations importantes entre pays**.

![Secondaire %](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/RFM%20Acheteurs%202e.png)

Parmi ces 89, **72 sont en Asie dont 41 en Corée du Sud, malgré la distance entre le pays et le stade**. Sauf au Maroc et au Côte d'Ivoire, ces clients **priorisent le marché secondaire** pour acheter leurs billets. En **Géorgie, par exemple, 98 % des dépenses brutes de 218K € viennent du marché secondaire**. Cela signifie que le PSG a la possibilité d'améliorer ses marges en dirigeant ces clients vers le marché primaire.

### 1200 Clients Persuadables par nos Partenaires ont un Pouvoir d'Achat Elevé

![Uplift Partenaires](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Uplift%20Spend%20Partners.png)

Ce sont des clients avec des scores RFM 414, 314, 313, 434, et 413. Autrement dit, ils sont nos clients assez récents avec un pouvoir d'achat élevé.

Ils ont acheté leurs derniers billets entre 0 et 431 jours avant le dernier match dans la BDD (2025-05-17). **La plupart ont fait 1 commande**, mais 36 d'entre eux sont des acheteurs fréquents avec 3-5 commandes. Ces clients rapportent en **moyenne 1355 € par client**. **19 % de ces clients sont des femmes**. La plupart de ces clients sont en Asie (1100), avec le **Corée du Sud encore largement en tête (70 %)**. Des clients venant de ce pays ont un ARPU de 826 €.

Ces clients identifiés ont donné leur consentement aux sponsors et ont un pouvoir d'achat élevé. Même s'ils ne reviennent pas au stade, ils peuvent être des cibles lucratifs pour des offres sponsoring et merchandising. Ce serait une méthode d'**améliorer leur affinité avec la marque PSG et nos sponsors afin de les fidéliser**.

### Évaluation du Risque de Churn

![Churn](https://raw.githubusercontent.com/Shree-Analyst/psg-case-study/refs/heads/main/rapports/Visualisations/Churn.png)

Selon la segmentation RFM, les clients riqués par le churn sont identifiés comme ceux ayant des **scores RFM 133, 134, 143, et 144**. Cela veut dire des clients qui n'ont pas achetés depuis longtemps, qui ont pourtant des dépenses élevées et fréquentes.

**24 clients sont identifiés**, dont 12 qui nous ont donné le consentement marketing. L'ensemble de ces clients contribuait aux **dépenses de 31,5K €** et ceux avec opt-in ont contribué 17K €.

Cela signifie que la **somme des dépenses que nous sommes en risque de perdre n'est pas massive (0,2 % des dépenses brutes)**. Donc, il faut **évaluer d'abord si un ciblage personnalisé vaut le coût en ROI** pour cette tranche de clients. Il est nécessaire de **solliciter les opinions des BUs Marketing et Billetterie** pour y répondre.

## Recommandations

### Synthèse des insights clés

Pour rappel, les insights sont séparés en 3 blocs :

#### Contextuels

- Un client Asiatique dépensera 320 €, achetera au marché secondaire 15 jours avant le match.
    - Lors de sa vie, il dépensera 680 €
- Un client Africain dépensera 2,3K €, achetera au marché primaire 9 jours avant le match, avec des différences importantes.
    - Lors de sa vie, il dépensera 7K €

#### Directionnels

- Différences statistiquement validées sont présentes en taux de conversion clients entre des pays.
- Différentes affinités des supporteurs pour le marketing PSG et partenaires selon pays
- 8 pays clés conduisent la quasi-totalité des dépenses : Guinée, Corée du Sud, Japon, Maroc, Chine, Côte d'Ivoire, Bénin, et Inde ; avec différences en consommation.
    - La Guinée est un petit marché avec des clients de très haute valeur.
    - La Corée du Sud est un grand marché avec des clients de moyenne valeur.
    - Le Maroc est un marché de taille moyenne avec des clients de haute valeur.
- Les matchs chocs attirent plus de dépenses avec différences en comportements de consommation.
    - Les fans Asiatiques ont acheté des billets au marché secondaire pour les matchs contre les équipes anglaises.
    - Les fans Africains ont acheté des billets au marché primaire pour les matchs contre des rivaux français et continentaux.
- Les clients en risque de churn sont peu nombreuses (12 clients avec opt-in) et les dépenses peu élevées (17K €).

#### Actionnables

- Avec des campagnes ciblées qui améliorent le taux de conversion global de 30 %, nous pouvons convertir 1,4K prospects supplémentaires en clients billetterie ou abonnés.
    - Corée du Sud, Japon, Chine, et Géorgie sont des pays les plus intéressants pour ça.
    - D'autres pays ne convertiront pas de prospects supplémentaires avec du ciblage.
- Pour le PSG, uplifter des dépenses est possible avec le ciblage de seulement 89 clients rajoutant 160K €.
- Pour les sponsors et pour les marchandises, il est possible de cibler 1,2K clients existants avec pouvoirs d'achat élevés.
- 10 % de clients ne viennent pas au matchs.

### Recommandations

Le but des BUs est à savoir quelles actions mener pour améliorer la stratégie d'engagement en Asie & en Afrique. Pour cela, on peut formuler 3 recommandations :

#### R1 : Activation des Prospects Persuadables en 15 Pays

Lancer des campagnes emails pour **activer les 47K prospects en 15 pays** pour améliorer le taux de conversion client de 30 % et **convertir 1,6K clients supplémentaires**.
- Proposer des offres billetterie aux prospects tels que les packs du match de Ligue 1, les promotions sur les achats directs, etc.
- **Contacter les prospects 2,5 x Lead Time Moyen du pays** pour leur donner du temps de planifier leurs trajets.
- Activer les prospects en **Corée du Sud avec des campagnes hyper-ciblées** car ce pays peut apporter 1,1K clients ou abonnés supplémentaires.
- Cibler les campagnes selon pays en utilisant des **assets locaux, tel que Lee-Kang In pour La Corée du Sud ou Kvaratskhelia pour la Géorgie**.

#### R2 : Activation des 89 Clients Persuadables par le PSG

Utiliser des **stratégies personnalisées pour activer les 89 clients** fréquents de haute valeur pour améliorer les dépenses brutes de 10 % et **ajouter 160k de valeur**.
- Parmi ces clients, cibler les **74 en Asie avec des offres de la billetterie PSG** pour diriger les dépenses vers le canal direct qui est plus rentable.
- **Ajuster les stratégie selon l'âge** du client, car les clients Asiatiques ont en moyenne 34 ans alors que les Africains 41 ans.
- Traiter les clients de **haute valeur venant du Maroc avec un personnalisation VIP**.

#### R3 : Activation des 1,2K Clients Persuadables par les Partenaires

Activer les **1,2K clients de haute valeur** avec des offres sponsorship par email pour **améliorer leurs dépenses, affinité avec la marque, et avec nos sponsors** grâce à un pouvoir d'achat élevé.
- La plupart de ces clients étant en Asie, dont **720 en Corée du Sud, concentrer les efforts sur ce pays** en proposant des marchandises vendeurs.
- Collaborer avec **Qatar Airways pour proposer des offres de billet d'avion** pour le prochain déplacement de ces clients.

#### R4 : Programme No-Show Resell

**Rappeler clients du match 24 heures avant le match** et les informer de la possibilité de revendre leurs billets en cas d'imprévus.
- **Prioriser clients Africains**, parce qu'ils achètent leurs billets plus proche du match et dépensent 7-10 fois plus que les clients Asiatiques.

## Notes

### Prochaines Étapes

Selon les insights directionnels et les dimensions dépriorisées pour cette analyse, les étapes suivantes peuvent renforcer l'analyse :
- **Definir une méthode de calcul de revenue** en basant sur le prix primaire, et un moyen de calculer le prix primaire si absent dans les données. **Utiliser le revenue au lieu des dépenses brutes** pour renforcer la crédibilité de l'analyse pour les BUs billetterie et marketing.
- **Segmenter les no-shows** pour savoir qui ne vient pas au stade et ratrapper les opportunités des double ventes en collaboration avec le BU billetterie.
- Invesitguer avec le BU billetterie pour définir une **stratégie pour adresser churn potentiel** des clients.
- Ajouter **dimensions du mois de match et l'emplacement des sièges** pour analyser plus prondémment les comportements clients.
- Investiguer avec le BU billetterie la **signification des différents 'contingents'** avant de l'ajouter comme dimension d'analyse, surtout pour des clients VIP.

### Caveats

Les points suivants sont à noter dans cette analyse :
- 70 % de supporteurs n'ont pas indiqué leurs civilité, ce qui fait impossible de recommander les stratégies personnalisées pour des prospects.
- Quelques supporteurs ont indiqués des dates de naissances fausses, leur donnant des âges de >300 ans, par exemple. Représentant moins de 0,1 % des données, ces âges sont exclus du tableau de bord.
- La métrique « Dépenses Brutes » ne sert pas à calculer le ROI potentiel des actions marketing mais de simplement juger le pouvoir d'achat d'un supporteur.