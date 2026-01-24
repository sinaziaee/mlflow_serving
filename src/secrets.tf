############################
# Secrets Manager (DB creds)
############################

resource "random_password" "db" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db" {
  name_prefix = "mlflow-db-"
  tags        = { Name = "mlflow-db-secret" }
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  secret_string = jsonencode({
    username = "mlflow"
    password = random_password.db.result
  })
}