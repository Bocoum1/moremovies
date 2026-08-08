#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LOCAL_DIR="$ROOT_DIR/mondrian/local"
PDI_LIB_DIR="$ROOT_DIR/tools/pdi-ce-9.4.0.0-343/data-integration/lib"
BUILD_DIR="$LOCAL_DIR/build"
MAIN_CLASS="RunMdx"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <query.mdx>" >&2
  exit 1
fi

QUERY_FILE="$1"

if [[ ! -f "$QUERY_FILE" ]]; then
  echo "Query file not found: $QUERY_FILE" >&2
  exit 1
fi

if [[ -f "$LOCAL_DIR/mondrian.env" ]]; then
  # shellcheck disable=SC1091
  source "$LOCAL_DIR/mondrian.env"
fi

mkdir -p "$BUILD_DIR"

javac \
  -cp "$PDI_LIB_DIR/*" \
  -d "$BUILD_DIR" \
  "$LOCAL_DIR/RunMdx.java"

java \
  -cp "$BUILD_DIR:$PDI_LIB_DIR/*" \
  "$MAIN_CLASS" \
  "$QUERY_FILE"
