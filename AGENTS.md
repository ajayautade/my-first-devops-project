# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Common commands
All commands assume repo root.

### Local Kubernetes (kind) workflow
- Create the kind cluster (name: `devops`):
  - `make kind-up`
- Build the Docker image locally (tag: `myapp:local`):
  - `make docker-build`
- Deploy to kind using Helm (loads the local image into kind first):
  - `make deploy-local`
- Tear down the cluster:
  - `make kind-down`

Notes:
- Cluster creation and deploy logic lives in `scripts/kind-up.sh` and `scripts/deploy-local.sh`.
- The Kubernetes Service created by Helm is `svc/myapp` (see `helm/myapp/templates/service.yaml`).

### Tests (Python)
Local tests run inside a repo-local virtualenv (`.venv`) because some macOS Python installs block system-wide `pip install`.
- Run the full unit test suite:
  - `make test`
- Run a single test file:
  - `.venv/bin/python -m pytest -q app/tests/test_health.py`
- Run a single test (by name):
  - `.venv/bin/python -m pytest -q app/tests/test_health.py -k test_health`

### Helm
- Lint the Helm chart:
  - `make helm-lint`

### Terraform (AWS, optional)
Terraform code is in `infra/terraform/`.
- Format Terraform:
  - `make tf-fmt`
- Validate Terraform (no backend):
  - `make tf-validate`

To create AWS resources (ECR repo + IAM role for GitHub Actions via OIDC), run from `infra/terraform/`:
- `terraform init`
- `terraform plan -var aws_region=... -var github_org=... -var github_repo=my-first-devops-project -var ecr_repo_name=my-first-devops-project`
- `terraform apply`

## Architecture overview (big picture)
This repo is structured to demonstrate an end-to-end DevOps flow: build/test a containerized service, deploy it locally to Kubernetes via Helm, and publish images via CI (GHCR) with an optional path to AWS ECR using Terraform + GitHub OIDC.

### App → container image
- The application is a minimal FastAPI service in `app/main.py` with `/` and `/health` endpoints.
- `Dockerfile` builds a container image that runs `uvicorn app.main:app` on port 8000.

### Container image → Kubernetes (kind) via Helm
- The Helm chart is in `helm/myapp/`.
- `values.yaml` controls which image gets deployed (`image.repository`, `image.tag`, and `image.pullPolicy`).
- `scripts/deploy-local.sh` assumes you built `myapp:local`, loads it into kind (`kind load docker-image ...`), then installs/upgrades the Helm release `myapp`.

### CI/CD (GitHub Actions)
- `.github/workflows/ci.yml` runs on PRs and pushes to `main`:
  - Python unit tests
  - `helm lint`
  - `terraform fmt -check` for `infra/terraform`
  - Docker build; on `main` it also pushes to GHCR (`ghcr.io/<owner>/my-first-devops-project`) tagged with `latest` and the commit SHA.

### AWS ECR publishing (optional)
- `infra/terraform/` provisions:
  - an ECR repository
  - an IAM role trusted by GitHub Actions (OIDC) scoped to `refs/heads/main` for a specific `github_org/github_repo`
- `.github/workflows/aws-ecr.yml` is a manually-triggered workflow (`workflow_dispatch`) that:
  - assumes `vars.AWS_ROLE_ARN` via OIDC
  - logs into ECR
  - builds and pushes an image to `vars.ECR_REPOSITORY` tagged with the commit SHA

If working on AWS/ECR integration, keep the coupling in mind:
- Terraform variables `github_org` + `github_repo` must match the GitHub repository owner/name.
- GitHub Actions expects repo Variables (not Secrets) to be set: `AWS_REGION`, `AWS_ROLE_ARN`, `ECR_REPOSITORY` (as described in `README.md`).
