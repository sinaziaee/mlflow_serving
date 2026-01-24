resource "aws_cloudwatch_log_group" "mlflow" {
  name              = "/ecs/mlflow"
  retention_in_days = 14
}

resource "aws_ecs_cluster" "main" {
  name = "mlflow-cluster"
}

############################
# ALB + Target Group + Listener
############################

resource "aws_lb" "mlflow" {
  name               = "mlflow-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "mlflow" {
  name        = "mlflow-tg"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.mlflow.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mlflow.arn
  }
}

############################
# ECS Task Definition
############################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  # We stored {"username":"mlflow","password":"..."} in the secret JSON.
  db_user = "mlflow"
  db_name = "mlflow"

  # Construct without password; password injected as env var MLFLOW_DB_PASSWORD
  db_uri = "postgresql://${local.db_user}:$${MLFLOW_DB_PASSWORD}@${aws_db_instance.mlflow.address}:5432/${local.db_name}"
}

resource "aws_ecs_task_definition" "mlflow" {
  family                   = "mlflow-server"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "mlflow"
      image     = "${aws_ecr_repository.mlflow.repository_url}:latest"
      essential = true

      portMappings = [
        { containerPort = 5000, hostPort = 5000, protocol = "tcp" }
      ]

      environment = [
        { name = "MLFLOW_BACKEND_STORE_URI",    value = local.db_uri },
        { name = "MLFLOW_DEFAULT_ARTIFACT_ROOT", value = "s3://${aws_s3_bucket.mlflow_artifacts.bucket}/artifacts" }
      ]

      secrets = [
        {
          name      = "MLFLOW_DB_PASSWORD"
          valueFrom = "${aws_secretsmanager_secret.db.arn}:password::"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.mlflow.name
          awslogs-region        = data.aws_region.current.name
          awslogs-stream-prefix = "mlflow"
        }
      }
    }
  ])
}

############################
# ECS Service
############################

resource "aws_ecs_service" "mlflow" {
  name            = "mlflow-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.mlflow.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = aws_subnet.private[*].id
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.mlflow.arn
    container_name   = "mlflow"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]
}