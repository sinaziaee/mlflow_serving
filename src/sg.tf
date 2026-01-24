############################
# Security Groups
############################

resource "aws_security_group" "ecs_tasks" {
  name        = "mlflow-ecs-tasks-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  # outbound anywhere (via NAT in private subnets)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mlflow-ecs-tasks-sg" }
}

resource "aws_security_group" "rds" {
  name        = "mlflow-rds-sg"
  description = "Allow Postgres from ECS tasks only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Postgres from ECS tasks"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "mlflow-rds-sg" }
}