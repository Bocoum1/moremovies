#!/usr/bin/env bash
set -euo pipefail

OUTDIR="$(cd "$(dirname "$0")" && pwd)"

MYSQL_HOST="${PBI_EXPORT_MYSQL_HOST:-127.0.0.1}"
MYSQL_PORT="${PBI_EXPORT_MYSQL_PORT:-3306}"
MYSQL_DB="${PBI_EXPORT_MYSQL_DB:-mm_warehouse}"
MYSQL_USER="${PBI_EXPORT_MYSQL_USER:-mondrian_user}"
MYSQL_PASSWORD="${PBI_EXPORT_MYSQL_PASSWORD:-}"

if [[ -z "${MYSQL_PASSWORD}" ]]; then
  echo "PBI_EXPORT_MYSQL_PASSWORD is required." >&2
  exit 1
fi

run_query_to_tsv() {
  local outfile="$1"
  local sql="$2"

  MYSQL_PWD="${MYSQL_PASSWORD}" mysql \
    --host="${MYSQL_HOST}" \
    --port="${MYSQL_PORT}" \
    --user="${MYSQL_USER}" \
    --database="${MYSQL_DB}" \
    --batch \
    --raw \
    --execute="${sql}" > "${OUTDIR}/${outfile}"
}

run_query_to_tsv "01_ca_mensuel_par_magasin.tsv" "
SELECT
  a.annee,
  a.mois,
  m.nom_magasin,
  a.ca_vente,
  a.ca_location,
  a.ca_total
FROM AGG_CA_MOIS_MAGASIN a
JOIN DIM_MAGASIN m ON a.magasin_key = m.magasin_key
ORDER BY a.annee, a.mois, m.nom_magasin;
"

run_query_to_tsv "02_ventes_mensuelles_par_produit.tsv" "
SELECT
  a.annee,
  a.mois,
  m.nom_magasin,
  p.titre,
  p.type_produit,
  p.categorie_produit,
  a.ca_vente,
  a.nombre_ventes
FROM AGG_VENTE_MOIS_MAGASIN_PRODUIT a
JOIN DIM_MAGASIN m ON a.magasin_key = m.magasin_key
JOIN DIM_PRODUIT p ON a.produit_key = p.produit_key
ORDER BY a.annee, a.mois, m.nom_magasin, p.type_produit, p.titre;
"

run_query_to_tsv "03_ventes_mensuelles_films.tsv" "
SELECT
  a.annee,
  a.mois,
  m.nom_magasin,
  p.titre,
  a.ca_vente,
  a.nombre_ventes
FROM AGG_VENTE_MOIS_MAGASIN_PRODUIT a
JOIN DIM_MAGASIN m ON a.magasin_key = m.magasin_key
JOIN DIM_PRODUIT p ON a.produit_key = p.produit_key
WHERE p.type_produit = 'film'
ORDER BY a.annee, a.mois, m.nom_magasin, p.titre;
"

run_query_to_tsv "04_locations_mensuelles_films.tsv" "
SELECT
  a.annee,
  a.mois,
  m.nom_magasin,
  p.titre,
  a.ca_location,
  a.nombre_locations,
  a.duree_location_totale
FROM AGG_LOCATION_MOIS_MAGASIN_PRODUIT a
JOIN DIM_MAGASIN m ON a.magasin_key = m.magasin_key
JOIN DIM_PRODUIT p ON a.produit_key = p.produit_key
WHERE p.type_produit = 'film'
ORDER BY a.annee, a.mois, m.nom_magasin, p.titre;
"

run_query_to_tsv "05_locations_films_clients_age_genre.tsv" "
SELECT
  d.annee,
  d.mois,
  m.nom_magasin,
  p.titre,
  c.genre,
  c.age,
  c.tranche_age,
  c.groupe_age,
  fl.nombre_locations,
  fl.montant_location,
  fl.duree_location_jours
FROM FACT_LOCATION fl
JOIN DIM_PERIODE d ON fl.date_key = d.date_key
JOIN DIM_MAGASIN m ON fl.magasin_key = m.magasin_key
JOIN DIM_PRODUIT p ON fl.produit_key = p.produit_key
JOIN DIM_CLIENT c ON fl.client_key = c.client_key
WHERE p.type_produit = 'film'
ORDER BY d.annee, d.mois, m.nom_magasin, p.titre, c.genre, c.age;
"

python3 - <<'PY' "${OUTDIR}"
from pathlib import Path
import csv
import sys

outdir = Path(sys.argv[1])
for tsv_path in outdir.glob("*.tsv"):
    csv_path = tsv_path.with_suffix(".csv")
    with tsv_path.open("r", encoding="utf-8", newline="") as src, csv_path.open(
        "w", encoding="utf-8", newline=""
    ) as dst:
        reader = csv.reader(src, delimiter="\t")
        writer = csv.writer(dst)
        writer.writerows(reader)
PY

echo "Power BI exports generated in: ${OUTDIR}"
