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

# reads current version from version file
VERSION := $(shell cat VERSION)

# tmp folder, used to store the short-lived temporary files
TMP_DIR := tmp

# changelog_notes file, contains log increments generated during a release
CHANGELOG_NOTES_FILE := changelog_notes.md

# docker folder, where build time artifacts go in 
DOCKER_DIST_DIR := dist/docker

# path to psql cmd
PSQL_CMD := /Library/PostgreSQL/15/bin/psql

COMMON_GIT := https://github.com/enabletechnologies/common.git
COMMON_DIR := ../common

# branch root, for (main-fixes, main) it is main, for (lts-fixes, lts) it is lts
BRANCH_ROOT := $(shell git branch --show-current | awk -F\- '{print $1}')

# python version used by uv and others
PYTHON_VERSION := 3.13

# deploy directory, where the common scripts are located
DEPLOY_DIR ?= ../deploy

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
	@uv venv info

init: ## Initializes the project. Run this after cloning the repository.
	@[ -e .env ] || cp .env.example .env
	@pre-commit install
	@$(MAKE) install || exit 1

init_f: ## Force initializes the project. Run this if you want to reset your virtual env and env parameters
	@[ -e .env ] && rm .env || true
	@[ -e .dockerenv ] && rm .dockerenv || true
	@[ -d .venv ] && rm -rf .venv || true
	@$(MAKE) init || exit 1

install: ## Install the project dependencies in dev mode.
	@uv venv -p $(PYTHON_VERSION) --allow-existing && uv sync --all-extras --active --frozen
	@echo "Please run 'make install_f' if you have manually updated dependencies in pyproject.toml."

install_f: ## Install the project dependencies in dev mode and synchronize uv.lock if required.
	@[ -d .venv ] && rm -rf .venv || true
	@uv lock
	@$(MAKE) install || exit 1

format: ## Format code using ruff & typos.
	@uv run ruff check src tests --fix
	@uv run ruff format src tests

lint: ## Lint source code, docs, etc.
	@uv run mypy -p enable.pre_commit_hooks
	@uv run typos || exit 1
	@uv run ruff check src tests || exit 1
	@uv run ruff format src tests --check || exit 1

lint_docs: ## Lint docs.
	@markdownlint docs

format_docs: ## Format docs.
	@markdownlint --fix docs


numthreads ?=auto
test: ## Run tests.
	@DEFAULT_TENANT_ID=enabletest make upgrade
	@uv run pytest -v tests/ -n $(numthreads) --cov --dist=loadscope --maxprocesses=6

test_cov: ## Run tests and generate coverage report.
	@$(MAKE) test || exit 1
	@uv run coverage report --show-missing
	@uv run coverage html
	@uv run coverage xml

shell: ## Open a shell in the project.
	@echo "Please run source $(VENV_BIN)/activate to activate the virtual environment." 	

start: ## Starts the application.
	@$(MAKE) install || exit 1
ifeq (prod, $(m))
	@echo 'Starting app in production mode. Reload is disabled!'
	@uv run uvicorn app.main:app --host=$(APP_HOST) --port=$(APP_PORT) --no-server-header --forwarded-allow-ips="*" --proxy-headers --workers=2 &
else
	@uv run uvicorn app.main:app --host=$(APP_HOST) --port=$(APP_PORT) --no-server-header --forwarded-allow-ips="*" --proxy-headers --reload &
endif


update_dependencies: ## Update dependencies
	@echo "Note that this will not update versions for dependencies outside their version constraints specified in the pyproject.toml file."
	@echo "To force update a dependency to latest version, use n (name) flag (e.g. n=pydantic). Use v (version) flag to update to a specific version"
	@echo "To force update 'enable-common' package, v (version) flag is also required (e.g. n=enable-common v=0.0.6rc2)"
ifneq (, $(n))
	@uv add $(n)@$(v)
else
	@uv lock --upgrade
	@$(MAKE) format || exit 1
	@git add -A && git diff-index --quiet HEAD || git commit -m "chore(deps): update dependencies"
endif

update_deps: update_dependencies # alias for update_dependencies

check_dependencies: ## Check dependencies for latest available version
	@uv lock --upgrade --dry-run

check_deps: check_dependencies # alias for check_dependencies

release_rc: ## Releases RC version for next patch version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment PATCH -pr rc --yes --no-verify --git-output-to-stderr --retry --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --retry
	@$(MAKE) project_build
	@git push origin --tags

release_minor_rc: ## Releases RC version for next minor version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MINOR -pr rc --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --retry
	@$(MAKE) project_build
	@git push origin --tags

release_major_rc: ## Releases RC version for next major version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MAJOR -pr rc --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --retry
	@$(MAKE) project_build
	@git push origin --tags

release: ## Releases next patch version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
ifneq (, $(v))
	@cz bump --git-output-to-stderr --changelog-to-stdout $(v) > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --retry
else
	@cz bump --increment PATCH --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --retry
endif
	@$(MAKE) project_build
	@git push origin --tags

release_minor: ## Releases next minor version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MINOR --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --retry
	@$(MAKE) project_build
	@git push origin --tags

release_major: ## Releases next major version
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@cz bump --increment MAJOR --git-output-to-stderr --changelog-to-stdout > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --retry
	@$(MAKE) project_build
	@git push origin --tags

release_calver: ## Releases next minor rc version for the calver versioning scheme
	@cz bump --git-output-to-stderr --changelog-to-stdout $$(date +%y.%-m.0rc0) --retry
	@$(MAKE) project_build
	@git push origin --tags

project_build: ## Builds the project
	@uv sync --all-extras && git add -A && git diff-index --quiet HEAD || git commit -m "build(project): build projects" --no-verify

docker_build: ## Builds the images
	$(eval ARTIFACT_REGISTRY := 'us-docker.pkg.dev/methodical-bee-392317/enable')
	@docker buildx build -t $(APP_NAME):$(VERSION) --build-arg BASEBRANCH=$(BRANCH_ROOT) --build-arg IMAGETAG=$(VERSION) --build-arg IMAGE=$(APP_NAME) --build-arg ARTIFACT_REGISTRY=$(ARTIFACT_REGISTRY) -f docker/Dockerfile .


docker_up: ## Builds the images if the images do not exist and starts the containers
	@echo $(abspath $(PWD)/../deploy/secrets)
	@docker run -d --env-file .dockerenv -v ~/.config/gcloud:/home/999/.config/gcloud -p $(APP_PORT):8000 --name $(APP_NAME)  $(APP_NAME):$(VERSION) 

docker_down: ##  Stops the running containers, also removes the stopped containers as well as any networks that were created
	@docker stop $(APP_NAME)
	@docker rm $(APP_NAME)

docker_prune: ## Prunes unused (dangling) images from local docker registry
	@docker image prune -f
	@docker builder prune -f

seed: ## Deploys the functions to insert seed data and runs the seed script
	@AUTO_SEED_FORCE=true uv run python3 src/app/seed/main.py load

extract_seed: ## Extracts seed data from the application
ifeq (, $(f))
	@$(error f (file) flag (e.g. f=src/app/seed/002_product.json) not specified)
endif
	@uv run python3 src/app/seed/main.py extract -f $(f)

pull: ## Pulls latest changes
ifneq (, $(b))
	@git checkout $(b)
endif
	@git pull --rebase
	@$(MAKE) init || exit 1

stop: ## Stops the application
	@lsof -t -i:$(APP_PORT) | xargs -r -I {} pgrep -P {} | xargs -r kill
	@lsof -t -i:$(APP_PORT) | xargs -r kill
	@pgrep -f port=$(APP_PORT) | xargs -r kill

ping: ## Pings the application
	@curl http://localhost:$(APP_PORT)/api/$(APP_NAME)/diagnostics/ping | json_pp

health: ## Performs Health check on application
	@curl http://localhost:$(APP_PORT)/api/$(APP_NAME)/diagnostics/health | json_pp

push: ## Pushes local commits to remote repository
	@git push

restart: ## Restarts the application.
	@$(MAKE) stop start	

release_gh: ## Creates a new GitHub Release for given version using issues in related milestone
	@$(eval $@_v := $(or $(v),$(VERSION)))
	@[ -d $(TMP_DIR) ] || mkdir $(TMP_DIR)
	@node $(DEPLOY_DIR)/scripts/release/create_gh_release_log.mjs $(APP_NAME) "V$($@_v)" > $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
	@cat $(TMP_DIR)/$(CHANGELOG_NOTES_FILE)
ifneq (1, $(dry-run))
    ifneq (,$(findstring rc,$($@_v)))
		@gh release create v$($@_v) -F $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) -p --generate-notes -d
    else
		@gh release create v$($@_v) -F $(TMP_DIR)/$(CHANGELOG_NOTES_FILE) --generate-notes -d
    endif
endif