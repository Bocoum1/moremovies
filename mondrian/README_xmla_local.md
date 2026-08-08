# Serveur XML/A local

Le runner Java embarqué expose le catalogue Mondrian sur un endpoint XML/A
local, utilisable par un client compatible SOAP/XMLA.

## Prérequis

- `mm_warehouse` créée et alimentée ;
- `mondrian/local/mondrian.env` configuré ;
- utilisateur MySQL disposant d'un accès en lecture seule à l'entrepôt ;
- bibliothèques Mondrian, olap4j et Jetty disponibles localement.

## Démarrage

```bash
./mondrian/local/run_xmla_server.sh
```

Par défaut, le catalogue `MoreMoviesWarehouse` est publié à l'adresse
`http://localhost:8888/xmla`. Le port et le chemin peuvent être modifiés avec
`MONDRIAN_XMLA_PORT` et `MONDRIAN_XMLA_PATH`.

## Vérification

Tester d'abord la découverte du catalogue, puis l'exécution d'une requête :

```bash
./mondrian/local/test_xmla_discover.sh
./mondrian/local/test_xmla_execute.sh
```

Ce serveur est prévu pour le développement et la validation locale. Il ne
constitue pas une configuration de production.
