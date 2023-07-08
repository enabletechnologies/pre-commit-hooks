# ensures all recipe lines for each target will be provided to a single invocation of the shell.
.ONESHELL:

# makes help the default target
.DEFAULT_GOAL := help

# include .env properties
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# location of bin folder of virtual environment
# all commands are run from this folder
VENV_BIN:=.venv/bin

# location of alembic config file
ALEMBIC_CONFIG:=src/migrations.ini

# read app version from version file
APP_VERSION := $(shell cat VERSION)

help: ## Display this help message
	@echo "\033[1mUsage:\033[0m make <target>"
	@echo ""
	@echo "\033[1mTargets:\033[0m"
	@echo ""
	@awk -F '##' '/^[a-z_]+:[a-z ]+##/ { printf("\033[34m%-25s\033[0m %s\n", $$1, $$2) }' Makefile	

info: ## Show the current environment info.
	@echo "\033[1mApp name:\033[0m $(APP_NAME)"
	@echo "\033[1mApp prefix:\033[0m $(APP_PREFIX)"
	@echo "\033[1mApp version:\033[0m $(APP_VERSION)"
	@echo "\033[1mApp port:\033[0m $(APP_PORT)"
	@echo ""
	@echo "\033[1mCurrent environment:\033[0m"
	@poetry env info

init: ## Initializes the project. Run this after cloning the repository.
	@test -e .env || cp -n .env.example .env
	@pre-commit install	
	@make install	

install: ## Install the project in dev mode.
	@python3 -m venv .venv
	@poetry install

format: ## Format code using ruff & black.
	@$(VENV_BIN)/ruff src tests --fix
	@$(VENV_BIN)/black src tests

lint: ## Run ruff & black linters.
	@$(VENV_BIN)/ruff src tests
	@$(VENV_BIN)/black src tests --check

test: ## Run tests and generate coverage report.
	@$(VENV_BIN)/pytest -v --cov-config .coveragerc --cov=src/app -l --tb=short --maxfail=1 tests/
	@$(VENV_BIN)/coverage xml
	@$(VENV_BIN)/coverage html

shell: ## Open a shell in the project.
	@echo "Please run 'deactivate' to exit the shell"
	@poetry shell

start: ## Starts the application.
	@$(VENV_BIN)/uvicorn app.main:app --host=$(APP_HOST) --port=$(APP_PORT) --reload

upgrade: ## Run migrations upgrade using alembic
	@$(VENV_BIN)/alembic -c $(ALEMBIC_CONFIG) upgrade head

downgrade: ## Run migrations downgrade using alembic
	@$(VENV_BIN)/alembic -c $(ALEMBIC_CONFIG) downgrade -1

migrations: ## Generate a migration using alembic
	@$(VENV_BIN)/alembic -c $(ALEMBIC_CONFIG) revision --autogenerate --rev-id=$(APP_VERSION)_$$(date +%y%m%d%H%M%S)

requirements: ## Export the poetry lock file to requirements.txt file format
	@poetry export -f requirements.txt --output requirements.txt --without-hashes
	@poetry export -f requirements.txt --output requirements-dev.txt --without-hashes --only dev

update_dependencies: ## Update dependencies
	@echo "Please run 'poetry update requests toml' to update specific dependencies"
	@poetry update

release_rc: ## Releases RC version for next patch version
	@cz bump --increment PATCH -pr rc

release_minor_rc: ## Releases RC version for next minor version
	@cz bump --increment MINOR -pr rc

release_major_rc: ## Releases RC version for next minor version
	@cz bump --increment MAJOR -pr rc

release: ## Releases next patch version
	@cz bump --increment PATCH

release_minor: ## Releases next minor version
	@cz bump --increment MINOR

release_major: ## Releases next minor version
	@cz bump --increment MAJOR