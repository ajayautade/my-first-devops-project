.PHONY: kind-up kind-down docker-build deploy-local venv test helm-lint tf-fmt tf-validate

APP_NAME := myapp
KIND_CLUSTER := devops
IMAGE_LOCAL := $(APP_NAME):local
VENV := .venv

kind-up:
	./scripts/kind-up.sh

kind-down:
	./scripts/kind-down.sh

docker-build:
	docker build -t $(IMAGE_LOCAL) .

deploy-local: kind-up docker-build
	./scripts/deploy-local.sh

venv:
	python3 -m venv $(VENV)
	$(VENV)/bin/python -m pip install -U pip
	$(VENV)/bin/python -m pip install -r app/requirements.txt

test: venv
	$(VENV)/bin/python -m pytest -q

helm-lint:
	helm lint ./helm/myapp

tf-fmt:
	cd infra/terraform && terraform fmt -recursive

tf-validate:
	cd infra/terraform && terraform init -backend=false && terraform validate
