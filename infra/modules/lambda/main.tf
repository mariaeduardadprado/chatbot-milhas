# 1. Compacta o código Python em um arquivo ZIP
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/main.py"
  output_path = "lambda_function_payload.zip"
}

# 2. Define a Role do IAM para o Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "my_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# 3. Cria a função Lambda
resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "${var.name}-${var.environment}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "main.handler" # arquivo.funcao

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.9"

}