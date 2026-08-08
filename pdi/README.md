# Transformations Pentaho Data Integration

Les 40 transformations `.ktr` sont réparties selon les trois couches du flux
de données. Elles peuvent être ouvertes avec Spoon (Pentaho Data Integration
9.x).

## Ordre d'exécution

1. **Sources** : charger les données propres à chaque enseigne dans les bases
   `mm_src_*`.
2. **Intégration** : harmoniser les référentiels et alimenter
   `mm_integrated`.
3. **Entrepôt** : charger les dimensions avant les faits, puis construire les
   agrégats de `mm_warehouse`.

| Dossier | Rôle | Transformations |
|---|---|---:|
| `buckboaster/` | Clients, films, gadgets, acteurs et ventes | 8 |
| `metrostarlet/` | Clients, films, exemplaires, ventes et locations | 8 |
| `moviemegamart/` | Clients, catalogues, ventes et locations | 6 |
| `integrated/` | Référentiels et transactions harmonisés | 9 |
| `warehouse/` | Dimensions, faits et agrégats ROLAP | 9 |

## Configuration locale

Les connexions publiées utilisent volontairement les valeurs neutres
`change_me`. Les chemins d'entrée sont remplacés par
`/path/to/exports_csv/...`.

Avant toute exécution dans Spoon :

1. configurer les connexions MySQL de l'environnement local ;
2. renseigner les chemins vers les fichiers sources autorisés ;
3. exécuter les scripts SQL de [`sql/mysql`](../sql/mysql) ;
4. vérifier les types, les clés et le nombre de lignes à chaque couche.

Les mots de passe réels et les fichiers de données ne doivent jamais être
enregistrés dans les transformations versionnées.
