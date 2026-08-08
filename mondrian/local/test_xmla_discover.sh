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

DATASOURCE_INFO="${MONDRIAN_XMLA_DATASOURCE:-MoreMoviesWarehouse}"

curl -sS \
  -H 'Content-Type: text/xml; charset=utf-8' \
  -H 'SOAPAction: "urn:schemas-microsoft-com:xml-analysis:Discover"' \
  --data-binary @- \
  "http://localhost:${XMLA_PORT}${XMLA_PATH}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope
    xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/"
    xmlns:xmla="urn:schemas-microsoft-com:xml-analysis">
  <SOAP-ENV:Body>
    <xmla:Discover>
      <xmla:RequestType>DISCOVER_DATASOURCES</xmla:RequestType>
      <xmla:Restrictions />
      <xmla:Properties>
        <xmla:PropertyList>
          <xmla:DataSourceInfo>${DATASOURCE_INFO}</xmla:DataSourceInfo>
          <xmla:Content>SchemaData</xmla:Content>
          <xmla:Format>Tabular</xmla:Format>
        </xmla:PropertyList>
      </xmla:Properties>
    </xmla:Discover>
  </SOAP-ENV:Body>
</SOAP-ENV:Envelope>
EOF
