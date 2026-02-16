.PHONY: up down logs venv install pipeline dbt-build freshness report

up:
	docker compose up -d

down:
	docker compose down -v

logs:
	docker logs -f edu_dbt_prj_postgres

venv:
	python3 -m venv .venv && . .venv/bin/activate && python -m pip install --upgrade pip

install:
	. .venv/bin/activate && pip install -r requirements.txt

dbt-build:
	cd analytics && dbt deps && dbt build

freshness:
	cd analytics && dbt source freshness

report:
	. .venv/bin/activate && edr report --project-dir analytics --profiles-dir ~/.dbt

pipeline:
	. .venv/bin/activate && ./scripts/run_pipeline.sh
