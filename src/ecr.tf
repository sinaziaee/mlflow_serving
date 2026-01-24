resource "aws_ecr_repository" "mlflow" {
  name                 = "mlflow-server"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "mlflow-server"
  }
}

resource "aws_ecr_lifecycle_policy" "mlflow" {
  repository = aws_ecr_repository.mlflow.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 30
        }
        action = { type = "expire" }
      }
    ]
  })
}
