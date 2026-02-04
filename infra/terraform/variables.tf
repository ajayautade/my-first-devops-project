variable "aws_region" {
  type        = string
  description = "AWS region to deploy into (e.g. us-east-1)"
}

variable "github_org" {
  type        = string
  description = "GitHub user or org that owns the repo"
}

variable "github_repo" {
  type        = string
  description = "GitHub repo name (e.g. my-first-devops-project)"
}

variable "ecr_repo_name" {
  type        = string
  description = "ECR repository name"
}

variable "app_name" {
  type        = string
  description = "App name used for ECS/ALB resources"
  default     = "myapp"
}

variable "container_port" {
  type        = number
  description = "Container port exposed by the app"
  default     = 8000
}

variable "desired_count" {
  type        = number
  description = "Desired ECS service task count"
  default     = 1
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the demo VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets to create"
  default     = 2
}
