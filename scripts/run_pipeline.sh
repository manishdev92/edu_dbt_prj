#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "==> (1) Generate sample data"
python3 ingestion/generate_sample_data.py

echo "==> (2) Load into Postgres raw schemas"
python3 ingestion/load_to_warehouse.py

echo "==> (3) dbt build"
cd analytics
dbt deps
dbt build
dbt source freshness
cd ..

echo "==> (4) Elementary report"
edr report --project-dir analytics --profiles-dir ~/.dbt

echo ""
echo "✅ Pipeline complete."
echo "📄 Elementary report: $ROOT_DIR/edr_target/elementary_report.html"
