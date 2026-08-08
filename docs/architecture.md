# Architecture et règles d'intégration

## Flux de données

MoreMovies sépare les traitements en trois couches afin de conserver la
traçabilité entre les sources et le modèle analytique.

| Couche | Base | Rôle |
|---|---|---|
| Sources | `mm_src_buckboaster`, `mm_src_metrostarlet`, `mm_src_moviemegamart` | Reproduire les structures opérationnelles sans imposer un modèle commun |
| Intégration | `mm_integrated` | Harmoniser les référentiels et les transactions |
| Décisionnel | `mm_warehouse` | Optimiser les analyses multidimensionnelles |

## Harmonisation

Les transformations PDI appliquent notamment les opérations suivantes :

- normalisation des identifiants provenant de plusieurs systèmes ;
- unification des noms, genres, dates et attributs produits ;
- distinction commune entre les produits de type film et gadget ;
- rattachement de chaque transaction à son magasin d'origine ;
- dédoublonnage des référentiels avant le chargement ;
- dérivation des tranches d'âge et des attributs calendaires.

Les clés techniques de l'entrepôt isolent le modèle analytique des identifiants
propres aux applications sources. Les tables de faits conservent les mesures au
niveau transactionnel, tandis que les agrégats pré-calculent les indicateurs
mensuels les plus consultés.

## Correspondance des domaines

| Domaine commun | Buckboaster | Metrostarlet | MovieMegamart |
|---|---|---|---|
| Client | `CLIENT` | `CLIENT` | `CLIENT` |
| Produit film | `PRODUIT` + `FILM` | `FILM` + exemplaires | `REFERENCE_FILM` |
| Produit gadget | `PRODUIT` | Non disponible | `MODELE_GADGET` |
| Vente | `VENTE` | `VENTE` | `VENTE_FILM` + `VENTE_GADGET` |
| Location | Non disponible | `LOCATION` | `LOCATION_FILM` |

L'absence d'un domaine dans une source n'est pas compensée artificiellement :
elle est gérée comme une différence fonctionnelle du système d'origine.

## Couche analytique

Le fichier [`moremovies_schema.xml`](../mondrian/moremovies_schema.xml) relie le
modèle physique aux dimensions et mesures Mondrian. Deux cubes détaillés
exploitent les faits de vente et de location. Un troisième cube s'appuie sur
l'agrégat mensuel de chiffre d'affaires pour les vues de synthèse.

Les requêtes de [`mondrian/mdx`](../mondrian/mdx) couvrent les principaux axes
d'analyse : temps, magasin, produit et profil client.
