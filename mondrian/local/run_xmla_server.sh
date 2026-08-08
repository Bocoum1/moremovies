#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SID_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
PDI_LIB_DIR="${SID_ROOT}/tools/pdi-ce-9.4.0.0-343/data-integration/lib"
BUILD_DIR="${SCRIPT_DIR}/build-xmla"
ENV_FILE="${SCRIPT_DIR}/mondrian.env"

if [[ -f "${ENV_FILE}" ]]; then
  # shellcheck disable=SC1090
  source "${ENV_FILE}"
fi

mkdir -p "${BUILD_DIR}"

javac \
  -cp "${PDI_LIB_DIR}/*" \
  -d "${BUILD_DIR}" \
  "${SCRIPT_DIR}/RunXmlaServer.java"

exec java \
  -cp "${BUILD_DIR}:${PDI_LIB_DIR}/*" \
  RunXmlaServer
