resource "aws_ecr_repository" "this" {
  name = "${var.name}-${var.environment}"
}


resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "keep last 5 images"
      action       = {
        type = "expire"
      }
      selection     = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
    }]
  })
}
