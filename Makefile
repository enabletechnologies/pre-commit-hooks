# ensures all recipe lines for each target will be provided to a single invocation of the shell.
.ONESHELL:

# makes help the default target
.DEFAULT_GOAL := help

# include .env properties
ifneq (,$(wildcard ./.env))
    include .env
endif

# location of bin folder of virtual environment
# all commands are run from this folder
VENV_BIN:=.venv/bin

# location of alembic config file
ALEMBIC_CONFIG_FILE:=src/migrations.ini

# reads current version from version file
VERSION := $(shell cat VERSION)

# tmp folder, used to store the short-lived temporary files
TMP_DIR := tmp

# changelog_notes file, contains log increments generated during a release
CHANGELOG_NOTES_FILE := changelog_notes.md

# docker folder, where build time artifacts go in 
DOCKER_DIST_DIR := dist/docker

help: ## Display this help message
	@echo ""
	@echo "\033[1mUsage:\033[0m make TARGET"
	@echo ""
	@echo "Makefile contains the most useful commands to install, test, lint, format and release your project."
	@echo ""
	@echo "\033[1mTargets:\033[0m"
	@awk -F '##' '/^[a-z_]+:[a-z ]+##/ { printf("  \033[34m%-25s\033[0m %s\n", $$1, $$2) }' Makefile	

info: ## Show the current environment info.
	@echo "\033[1mApp name:\033[0m $(APP_NAME)"
	@echo "\033[1mApp prefix:\033[0m $(APP_PREFIX)"
	@echo "\033[1mApp version:\033[0m $(VERSION)"
	@echo "\033[1mApp port:\033[0m $(APP_PORT)"
	@echo ""
	@echo "\033[1mCurrent environment:\033[0m"
	@poetry env info

init: ## Initializes the project. Run this after cloning the repository.
	@[ -e .env ] || cp .env.example .env
	@[ -e .dockerenv ] || cp .dockerenv.example .dockerenv
	@pre-commit install
	@make install

install: ## Install the project in dev mode.
	@[ -d .venv ] || python3 -m venv .venv
	@. .venv/bin/activate
	@poetry install
	@poetry lock --no-update

format: ## Format code using ruff.
	@$(VENV_BIN)/ruff check src tests
	@$(VENV_BIN)/ruff format src tests

lint: ## Run ruff linters.
	@$(VENV_BIN)/mypy src tests
	@$(VENV_BIN)/ruff check src tests
	@$(VENV_BIN)/ruff format src tests --check

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
	@$(VENV_BIN)/alembic -c $(ALEMBIC_CONFIG_FILE) upgrade head

downgrade: ## Run migrations downgrade using alembic
	@$(VENV_BIN)/alembic -c $(ALEMBIC_CONFIG_FILE) downgrade -1

migrations: ## Generate a migration using alembic
	@$(VENV_BIN)/alembic -c $(ALEMBIC_CONFIG_FILE) revision --autogenerate --rev-id=$(VERSION)_$$(date +%y%m%d%H%M%S)

update_dependencies: ## Update dependencies
	@echo "Note that this will not update versions for dependencies outside their version constraints specified in the pyproject.toml file."
	@echo "To force update a dependency to latest version, use n (name) flag (e.g. n=pydantic). Use v (version) flag to update to a specific version"
	@echo "To force update 'enable-common' package, v (version) flag is also required (e.g. n=enable-common v=0.0.6rc2)"
ifeq (enable-common, $(n))
    ifeq (, $(v))
		@$(error v (version) flag (e.g. v=0.0.6rc2) not specified)
    endif	
	@poetry add git+https://github.com/enabletechnologies/common.git@v$(v)
else ifneq (, $(n))
	@poetry add $(n)@$(v)
else
	@poetry update
endif

update_deps: update_dependencies # alias for update_dependencies

check_dependencies: ## Check dependencies for latest available version
	@poetry show -l	

check_deps: check_dependencies # alias for check_dependencies

release_rc: ## Releases RC version for next patch version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment PATCH -pr rc --yes --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
	@make release_gh

release_minor_rc: ## Releases RC version for next minor version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MINOR -pr rc --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
	@make release_gh

release_major_rc: ## Releases RC version for next minor version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MAJOR -pr rc --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
	@make release_gh

release: ## Releases next patch version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment PATCH --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
	@make release_gh

release_minor: ## Releases next minor version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MINOR --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
	@make release_gh

release_major: ## Releases next minor version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MAJOR --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
	@make release_gh

init_f: ## Force initializes the project. Run this if you want to reset your virtual env and env parameters
	@[ -e .env ] && rm .env || true
	@[ -d .venv ] && rm -rf .venv || true
	@make init

release_gh: ## Creates a new GitHub Release for current version
	@git push origin
	@git push origin --tags
ifneq (,$(findstring rc,$(VERSION)))
	@gh release create v$(VERSION) -F $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) -p --generate-notes
else
	@gh release create v$(VERSION) -F $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --generate-notes
endif

docker_build: ## Builds the images
	@docker compose -f docker-compose.yml build

docker_up: ## Builds the images if the images do not exist and starts the containers
	@docker compose -f docker-compose.yml up -d

docker_down: ##  Stops the running containers, also removes the stopped containers as well as any networks that were created
	@docker compose -f docker-compose.yml down

docker_prune: ## Prunes unused (dangling) images from local docker registry
	@docker image prune -f
	@docker builder prune -f