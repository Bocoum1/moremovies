#!/usr/bin/env python3
"""Validate the public MoreMovies repository without external dependencies."""

from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

EXPECTED_TRANSFORMATIONS = 40
EXPECTED_SQL_TABLES = 37
REQUIRED_MDX_QUERIES = 5

FORBIDDEN_PATHS = {
    "docs/assets/qstion.png",
    "docs/assets/qstion2.png",
    "docs/github_checklist.md",
    "docs/portfolio_blurb.md",
    "pbi_exports/guide_binome_powerbi.md",
}


TEXT_SUFFIXES = {
    ".java",
    ".md",
    ".mdx",
    ".py",
    ".sh",
    ".sql",
    ".svg",
    ".xml",
}


def fail(message: str, errors: list[str]) -> None:
    errors.append(message)


def validate_xml(paths: list[Path], errors: list[str]) -> None:
    for path in paths:
        try:
            ET.parse(path)
        except ET.ParseError as exc:
            fail(f"XML invalide: {path.relative_to(ROOT)} ({exc})", errors)


def validate_public_content(errors: list[str]) -> None:
    for relative_path in FORBIDDEN_PATHS:
        if (ROOT / relative_path).exists():
            fail(f"Artefact privé détecté: {relative_path}", errors)

    for path in ROOT.rglob("*"):
        if not path.is_file() or ".git" in path.parts:
            continue
        if path.resolve() == Path(__file__).resolve():
            continue
        if path.suffix.lower() not in TEXT_SUFFIXES:
            continue

        content = path.read_text(encoding="utf-8", errors="replace").lower()
        for marker in FORBIDDEN_TEXT:
            if marker in content:
                fail(
                    f"Marqueur interne '{marker}' dans {path.relative_to(ROOT)}",
                    errors,
                )


def main() -> int:
    errors: list[str] = []

    transformations = sorted((ROOT / "pdi").rglob("*.ktr"))
    mondrian_schemas = sorted((ROOT / "mondrian").glob("*.xml"))
    mdx_queries = sorted((ROOT / "mondrian" / "mdx").glob("[0-9][0-9]_*.mdx"))

    if len(transformations) != EXPECTED_TRANSFORMATIONS:
        fail(
            f"Transformations PDI: {len(transformations)} "
            f"(attendu: {EXPECTED_TRANSFORMATIONS})",
            errors,
        )

    if len(mdx_queries) != REQUIRED_MDX_QUERIES:
        fail(
            f"Requêtes MDX numérotées: {len(mdx_queries)} "
            f"(attendu: {REQUIRED_MDX_QUERIES})",
            errors,
        )

    table_count = 0
    for sql_file in (ROOT / "sql" / "mysql").glob("*.sql"):
        sql = sql_file.read_text(encoding="utf-8")
        table_count += len(re.findall(r"^CREATE\s+TABLE\b", sql, re.MULTILINE | re.IGNORECASE))

    if table_count != EXPECTED_SQL_TABLES:
        fail(f"Tables SQL: {table_count} (attendu: {EXPECTED_SQL_TABLES})", errors)

    validate_xml(transformations + mondrian_schemas, errors)
    validate_public_content(errors)

    if errors:
        print("Validation échouée :", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        "Validation réussie: "
        f"{len(transformations)} transformations PDI, "
        f"{table_count} tables SQL, "
        f"{len(mondrian_schemas)} schéma Mondrian et "
        f"{len(mdx_queries)} requêtes MDX."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
