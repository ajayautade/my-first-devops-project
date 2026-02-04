output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "IAM role to use with GitHub Actions OIDC (configure as AWS_ROLE_ARN repo variable)"
}

output "ecr_repository_url" {
  value       = aws_ecr_repository.this.repository_url
  description = "ECR repository URL"
}

output "alb_dns_name" {
  value       = aws_lb.this.dns_name
  description = "Public URL (DNS) for the application load balancer"
}

output "ecs_cluster_name" {
  value       = aws_ecs_cluster.this.name
  description = "ECS cluster name"
}

output "ecs_service_name" {
  value       = aws_ecs_service.this.name
  description = "ECS service name"
}

output "ecs_task_execution_role_name" {
  value       = aws_iam_role.ecs_task_execution.name
  description = "ECS task execution role name"
}

output "ecs_task_role_name" {
  value       = aws_iam_role.ecs_task.name
  description = "ECS task role name"
}
