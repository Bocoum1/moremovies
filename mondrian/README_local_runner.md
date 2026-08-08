# Exécuter une requête MDX localement

Le runner Java charge [`moremovies_schema.xml`](moremovies_schema.xml), se
connecte à `mm_warehouse` et exécute une requête du dossier [`mdx`](mdx).

## Prérequis

- Java JDK ;
- MySQL avec l'entrepôt alimenté ;
- bibliothèques Mondrian et olap4j disponibles dans le répertoire PDI attendu
  par `local/run_mdx.sh`.

Le chemin des bibliothèques peut être adapté dans le script si Pentaho est
installé ailleurs.

## Configuration

```bash
cp mondrian/local/mondrian.env.example mondrian/local/mondrian.env
```

Renseigner ensuite le chemin du catalogue et les paramètres de connexion. Un
utilisateur dédié en lecture seule est recommandé :

```sql
CREATE USER 'mondrian_user'@'localhost' IDENTIFIED BY 'change_me';
GRANT SELECT ON mm_warehouse.* TO 'mondrian_user'@'localhost';
FLUSH PRIVILEGES;
```

Le fichier `mondrian.env` est ignoré par Git.

## Exécution

Depuis la racine du dépôt :

```bash
./mondrian/local/run_mdx.sh \
  mondrian/mdx/01_ca_total_par_magasin_et_par_annee.mdx
```

Ce mode valide rapidement le catalogue et les requêtes sans déployer de
serveur XML/A.
