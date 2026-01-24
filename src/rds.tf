############################
# RDS Instance (Postgres)
############################

resource "aws_db_instance" "mlflow" {
  identifier = "mlflow-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = "db.t4g.micro" # cheap; ARM-based

  allocated_storage = 20
  storage_type      = "gp3"

  db_name  = "mlflow"
  username = jsondecode(aws_secretsmanager_secret_version.db.secret_string)["username"]
  password = jsondecode(aws_secretsmanager_secret_version.db.secret_string)["password"]

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = false
  multi_az            = false

  # no need for backups
  backup_retention_period = 0
  skip_final_snapshot     = true

  tags = { Name = "mlflow-postgres" }
}
