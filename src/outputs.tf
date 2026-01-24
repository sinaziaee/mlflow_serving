output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "mlflow_artifacts_bucket_name" {
  value = aws_s3_bucket.mlflow_artifacts.bucket
}

output "ecs_tasks_sg_id" {
  value = aws_security_group.ecs_tasks.id
}

output "rds_endpoint" {
  value = aws_db_instance.mlflow.address
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}

