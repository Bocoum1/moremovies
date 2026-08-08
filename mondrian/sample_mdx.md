# Requetes MDX de base

## 1. CA total par magasin et par annee

```mdx
SELECT
  {[Measures].[CA Total]} ON COLUMNS,
  CrossJoin(
    [Periode Agg].[Annee].Members,
    [Magasin].[Magasin].Members
  ) ON ROWS
FROM [CA Global Mensuel]
```

## 2. CA vente mensuel par magasin

```mdx
SELECT
  {[Measures].[CA Vente], [Measures].[Nombre Ventes]} ON COLUMNS,
  CrossJoin(
    [Periode].[Mois].Members,
    [Magasin].[Magasin].Members
  ) ON ROWS
FROM [Ventes]
```

## 3. Top produits par CA vente

```mdx
SELECT
  {[Measures].[CA Vente]} ON COLUMNS,
  TopCount(
    [Produit].[Produit].Members,
    10,
    [Measures].[CA Vente]
  ) ON ROWS
FROM [Ventes]
```

## 4. Locations par tranche d'age

```mdx
SELECT
  {[Measures].[Nombre Locations], [Measures].[CA Location]} ON COLUMNS,
  [Client].[Age].[Tranche Age].Members ON ROWS
FROM [Locations]
```

## 5. Duree moyenne de location par type de produit

```mdx
SELECT
  {[Measures].[Duree Moyenne Location]} ON COLUMNS,
  [Produit].[Type Produit].Members ON ROWS
FROM [Locations]
```
