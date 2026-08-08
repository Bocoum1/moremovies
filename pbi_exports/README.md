# Jeux de données pour Power BI

Le script [`export_pbi_tsv.sh`](export_pbi_tsv.sh) extrait cinq vues métier de
`mm_warehouse`. Il produit un fichier CSV pour Power BI et un fichier TSV de
contrôle pour chaque requête.

| Export | Grain | Usage principal |
|---|---|---|
| `01_ca_mensuel_par_magasin` | mois et magasin | CA vente, location et total |
| `02_ventes_mensuelles_par_produit` | mois, magasin et produit | performance produit |
| `03_ventes_mensuelles_films` | mois, magasin et film | classement des films |
| `04_locations_mensuelles_films` | mois, magasin et film | volume et durée de location |
| `05_locations_films_clients_age_genre` | transaction, film et client | profil des clients locataires |

## Génération

```bash
PBI_EXPORT_MYSQL_PASSWORD='...' ./export_pbi_tsv.sh
```

Variables optionnelles :

- `PBI_EXPORT_MYSQL_HOST` (défaut : `127.0.0.1`) ;
- `PBI_EXPORT_MYSQL_PORT` (défaut : `3306`) ;
- `PBI_EXPORT_MYSQL_DB` (défaut : `mm_warehouse`) ;
- `PBI_EXPORT_MYSQL_USER` (défaut : `mondrian_user`).

Les exports générés contiennent des données et ne sont pas destinés à être
versionnés. La conception des pages et des mesures est décrite dans
[`reporting_specification.md`](reporting_specification.md).
