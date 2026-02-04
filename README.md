# My First DevOps Project
This repo is a DevOps portfolio project that demonstrates:
- A small containerized app (FastAPI)
- Local Kubernetes deployment using kind + Helm
- CI with GitHub Actions (tests, linting, Docker build)
- Optional AWS ECR image publishing using Terraform + GitHub Actions OIDC

## Repo layout
- `app/` FastAPI service + tests
- `Dockerfile` Container build
- `helm/myapp/` Helm chart for Kubernetes
- `infra/terraform/` AWS ECR + IAM (OIDC) for GitHub Actions
- `.github/workflows/` CI workflows
- `scripts/` local automation scripts

## Prerequisites (local)
- Docker Desktop (required for building images + kind)
- Homebrew packages (already installed if you ran `brew install ...`):
  - `kubectl`, `kind`, `helm`, `terraform`, `awscli`, `gh`, `jq`, `yq`

## Local tests
macOS Python installs often block system-wide `pip install` (PEP 668). Use the built-in virtualenv flow:
```bash
make test
```

## Quickstart: local Kubernetes (kind)
1) Create a cluster:
```bash
make kind-up
```

2) Deploy locally:
```bash
make deploy-local
```

3) Port-forward and test:
```bash
kubectl port-forward svc/myapp 8000:8000
curl http://localhost:8000/health
```

Cleanup:
```bash
make kind-down
```

## CI (GitHub Actions)
Workflow: `.github/workflows/ci.yml`
- Runs unit tests
- Runs `helm lint`
- Runs `terraform fmt -check` (on `infra/terraform`)
- Builds a Docker image
- On pushes to `main`, publishes the image to GHCR as:
  - `ghcr.io/<github_owner>/my-first-devops-project:latest`
  - `ghcr.io/<github_owner>/my-first-devops-project:<git_sha>`

## AWS: automatic deploy (ECR + ECS Fargate) using OIDC
This repo supports a full “push to `main` → deploy to AWS” flow:
- Terraform provisions **ECR + ECS Fargate + ALB** and an **OIDC IAM role** for GitHub Actions.
- `.github/workflows/ci.yml` pushes images to ECR and then updates the ECS service on pushes to `main`.

### 1) Create AWS resources (Terraform)
From `infra/terraform/`:
```bash
terraform init
terraform fmt
terraform validate
terraform plan \
  -var aws_region=us-east-1 \
  -var github_org=<your_github_user_or_org> \
  -var github_repo=my-first-devops-project \
  -var ecr_repo_name=my-first-devops-project
terraform apply
```

Terraform outputs you’ll use:
- `github_actions_role_arn` (set this as `AWS_ROLE_ARN` GitHub variable)
- `alb_dns_name` (your public app URL)

Notes:
- If your AWS account already has a GitHub OIDC provider configured, Terraform may need an import instead of creating a duplicate provider.

### 2) Set GitHub repo Variables
In your GitHub repo: Settings → Secrets and variables → Actions → Variables
Add:
- `AWS_REGION` (e.g. `us-east-1`)
- `AWS_ROLE_ARN` (Terraform output)
- `ECR_REPOSITORY` (ECR repo name, e.g. `my-first-devops-project`)

Optional (only if you changed names in Terraform):
- `ECS_CLUSTER` (default `myapp`)
- `ECS_SERVICE` (default `myapp`)
- `ECS_TASK_FAMILY` (default `myapp`)
- `ECS_CONTAINER_NAME` (default `myapp`)
- `ECS_CONTAINER_PORT` (default `8000`)
- `ECS_TASK_EXECUTION_ROLE_NAME` (default `myapp-ecs-task-execution`)
- `ECS_TASK_ROLE_NAME` (default `myapp-ecs-task`)

### 3) Deploy automatically
Every push to `main` runs the CI pipeline and (if the AWS variables above are set):
- Builds and pushes the container image to ECR tagged with:
  - the commit SHA
  - `latest`
- Registers a new ECS task definition revision
- Updates the ECS service and waits for it to become stable

Test the deployed app:
```bash
curl http://<alb_dns_name>/health
```

## How this project was created (high level)
- Created a minimal FastAPI app (`app/main.py`) + a small unit test suite (`app/tests/`).
- Containerized it with a simple `Dockerfile` running `uvicorn` on port 8000.
- Added local “DevOps workflow” helpers:
  - kind cluster scripts in `scripts/`
  - Helm chart in `helm/myapp/`
- Added GitHub Actions CI that runs tests + Helm lint + Terraform checks + an end-to-end deploy into kind.
- Added Terraform (`infra/terraform/`) for AWS infrastructure and GitHub OIDC permissions, enabling automatic deploy to ECS on pushes to `main`.
