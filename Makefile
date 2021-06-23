#* Variables
SHELL := /usr/bin/env bash
PYTHON := python

#* Poetry
.PHONY: poetry-download
poetry-download:
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | $(PYTHON) -

.PHONY: poetry-remove
poetry-remove:
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/install-poetry.py | $(PYTHON) - --uninstall

#* Installation
.PHONY: install
install:
	poetry lock -n && poetry export --without-hashes > requirements.txt
	poetry install -n
	poetry run mypy --install-types --non-interactive

.PHONY: pre-commit-install
install:
	poetry run pre-commit install

#* Formatters
.PHONY: codestyle
codestyle:
	-poetry run pyupgrade --py37-plus **/*.py
	poetry run isort --settings-path pyproject.toml **/*.py
	poetry run black --config pyproject.toml ./

.PHONY: formatting
formatting: codestyle

#* Linting
.PHONY: test
test:
	poetry run pytest

.PHONY: check-codestyle
check-codestyle:
	poetry run isort --settings-path pyproject.toml --check-only ./
	poetry run black --config pyproject.toml --diff --check ./
	poetry run darglint -v 2 ./

.PHONY: mypy
mypy:
	poetry run mypy --show-traceback --config-file pyproject.toml ./

.PHONY: check-safety
check-safety:
	poetry check
	poetry run pip check
	poetry run safety check --full-report
	poetry run bandit -r ./

.PHONY: lint
lint: test check-codestyle mypy check-safety

#* Cleaning
.PHONY: pycache-remove
pycache-remove:
	find . | grep -E "(__pycache__|\.pyc|\.pyo$$)" | xargs rm -rf

.PHONY: build-remove
build-remove:
	rm -rf build/

.PHONY: clean-all
clean-all: pycache-remove build-remove
