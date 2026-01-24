############################
# Secrets Manager (DB creds)
############################

resource "aws_secretsmanager_secret" "db" {
  name_prefix = "mlflow-db-"
  tags        = { Name = "mlflow-db-secret" }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}