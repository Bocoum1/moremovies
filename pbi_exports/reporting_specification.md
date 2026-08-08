# Spécification du reporting Power BI

Le rapport restitue les ventes et locations consolidées dans l'entrepôt
MoreMovies. Les pages proposées partagent des filtres sur la période, le
magasin et, lorsque cela est pertinent, le produit.

## 1. Vue d'ensemble

**Source** : `01_ca_mensuel_par_magasin`

- cartes KPI : CA total, CA vente et CA location ;
- histogramme : CA total par magasin ;
- courbe : évolution mensuelle du CA total ;
- filtres : année et magasin.

Cette page donne une lecture immédiate de l'activité et permet de comparer les
enseignes avant d'explorer les détails.

## 2. Performance des films

**Source** : `03_ventes_mensuelles_films`

- histogramme horizontal : cinq films au CA de vente le plus élevé ;
- courbe : évolution mensuelle du CA des films sélectionnés ;
- filtres : année et magasin.

Le classement doit utiliser un filtre Top N sur la somme de `ca_vente`.

## 3. Analyse des produits

**Source** : `02_ventes_mensuelles_par_produit`

- courbe : CA mensuel par produit ;
- tableau : titre, type, catégorie, CA et nombre de ventes ;
- filtres : type de produit, catégorie, magasin et titre.

## 4. Locations et profils clients

**Sources** : `04_locations_mensuelles_films` et
`05_locations_films_clients_age_genre`

- âge moyen des clients locataires par genre ;
- films les plus loués par magasin et par période ;
- matrice optionnelle des volumes par film et par mois.

Exemple de mesure :

```DAX
AgeMoyenClients =
    AVERAGE('05_locations_films_clients_age_genre'[age])
```

## 5. Détection des baisses de location

**Source** : `04_locations_mensuelles_films`

Cette page identifie, pour chaque film, les mois dont le nombre de locations
baisse de plus de 15 % par rapport au mois précédent. Une table calendrier et
une mesure temporelle explicite sont nécessaires pour éviter de comparer des
mois provenant d'années différentes.

```DAX
NbLocations =
    SUM('04_locations_mensuelles_films'[nombre_locations])

NbLocationsMoisPrecedent =
    CALCULATE([NbLocations], DATEADD('Calendrier'[Date], -1, MONTH))

VariationLocations =
    DIVIDE(
        [NbLocations] - [NbLocationsMoisPrecedent],
        [NbLocationsMoisPrecedent]
    )
```

Une mise en forme conditionnelle met en évidence les valeurs inférieures à
`-0,15`.
