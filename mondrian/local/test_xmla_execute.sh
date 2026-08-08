#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/mondrian.env"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

XMLA_PORT="${MONDRIAN_XMLA_PORT:-8888}"
XMLA_PATH="${MONDRIAN_XMLA_PATH:-/xmla}"
if [[ "${XMLA_PATH}" != /* ]]; then
  XMLA_PATH="/${XMLA_PATH}"
fi

DB_HOST="${MONDRIAN_DB_HOST:-localhost}"
DB_PORT="${MONDRIAN_DB_PORT:-3306}"
DB_NAME="${MONDRIAN_DB_NAME:-mm_warehouse}"
DB_USER="${MONDRIAN_DB_USER:-mondrian_user}"
DB_PASSWORD="${MONDRIAN_DB_PASSWORD:-}"
DB_PARAMS="${MONDRIAN_DB_PARAMS:-useUnicode=true&characterEncoding=UTF-8&serverTimezone=Europe/Paris}"
SCHEMA_PATH="${MONDRIAN_SCHEMA_PATH:-/path/to/moremovies_public/mondrian/moremovies_schema.xml}"

DATASOURCE_INFO="${MONDRIAN_XMLA_DATASOURCE_INFO:-Provider=mondrian;Jdbc=jdbc:mariadb://${DB_HOST}:${DB_PORT}/${DB_NAME}?${DB_PARAMS};JdbcDrivers=org.mariadb.jdbc.Driver;JdbcUser=${DB_USER};JdbcPassword=${DB_PASSWORD};Catalog=file:${SCHEMA_PATH};}"
CATALOG_NAME="${MONDRIAN_XMLA_CATALOG:-MoreMoviesWarehouse}"

xml_escape() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  printf '%s' "${value}"
}

DATASOURCE_INFO_XML="$(xml_escape "${DATASOURCE_INFO}")"
CATALOG_NAME_XML="$(xml_escape "${CATALOG_NAME}")"

curl -sS \
  -H 'Content-Type: text/xml; charset=utf-8' \
  -H 'SOAPAction: "urn:schemas-microsoft-com:xml-analysis:Execute"' \
  --data-binary @- \
  "http://localhost:${XMLA_PORT}${XMLA_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xmla="urn:schemas-microsoft-com:xml-analysis"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <SOAP-ENV:Body>
    <xmla:Execute>
      <xmla:Command>
        <xmla:Statement>
          SELECT
            {[Measures].[CA Total]} ON COLUMNS,
            CrossJoin([Periode Agg].[Annee].Members, [Magasin].[Magasin].Members) ON ROWS
          FROM [CA Global Mensuel]
        </xmla:Statement>
        </xmla:Command>
      <xmla:Properties>
        <xmla:PropertyList>
          <xmla:DataSourceInfo>${DATASOURCE_INFO_XML}</xmla:DataSourceInfo>
          <xmla:Catalog>${CATALOG_NAME_XML}</xmla:Catalog>
          <xmla:Format>Tabular</xmla:Format>
          <xmla:AxisFormat>TupleFormat</xmla:AxisFormat>
          <xmla:Content>Data</xmla:Content>
        </xmla:PropertyList>
      </xmla:Properties>
    </xmla:Execute>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
EOF
