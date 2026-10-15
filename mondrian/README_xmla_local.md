# Serveur XML/A local

## Prérequis

- `mm_warehouse` créée et alimentée ;
- `mondrian/local/mondrian.env` configuré ;
- utilisateur MySQL disposant d'un accès en lecture seule à l'entrepôt ;
- bibliothèques Mondrian, olap4j et Jetty disponibles localement.

## Démarrage

```bash
./mondrian/local/run_xmla_server.sh
```

## Vérification

Tester d'abord la découverte du catalogue, puis l'exécution d'une requête :

```bash
./mondrian/local/test_xmla_discover.sh
./mondrian/local/test_xmla_execute.sh
```
