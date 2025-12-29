# 1. Zip para a Lambda de Processamento (Handler)
data "archive_file" "lambda_handler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-handler.py"
  output_path = "${path.module}/lambda_handler_payload.zip"
}

# Zip para a Lambda de Entrega (Delivery)
data "archive_file" "lambda_delivery_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-delivery.py"
  output_path = "${path.module}/lambda_delivery_payload.zip"
}

# 2. Role do IAM (Identidade do Lambda)
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

# 3. Tópicos SNS (fan in e fan out)
resource "aws_sns_topic" "user_messages_topic" {
  name = "user-messages-fan-in-topic"
}

resource "aws_sns_topic" "response_topic" {
  name = "response-fan-out-topic"
}

# 4. Lambda Handler (transforma em Uppercase)
resource "aws_lambda_function" "message_handler" {
  filename      = data.archive_file.lambda_handler_zip.output_path
  function_name = "message_handler_func"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda-handler.lambda_handler" 
  runtime       = "python3.9"
  
  environment {
    variables = {
      RESPONSE_TOPIC_ARN = aws_sns_topic.response_topic.arn
    }
  }

  source_code_hash = data.archive_file.lambda_handler_zip.output_base64sha256
}

# 5. Lambda Delivery (Entrega final)
resource "aws_lambda_function" "delivery_func" {
  filename      = data.archive_file.lambda_delivery_zip.output_path
  function_name = "delivery_func"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda-delivery.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_delivery_zip.output_base64sha256
}

# 6. Políticas de IAM para Publicação
resource "aws_iam_policy" "lambda_sns_publish" {
  name        = "lambda_sns_publish_policy"
  description = "Permite que a lambda publique no tópico de resposta"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        Resource = aws_sns_topic.response_topic.arn
      },
      # Adicionado permissão básica de logs para facilitar debug
      {
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sns_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}

# 7. Permissões de Invocação
resource "aws_lambda_permission" "allow_sns_to_handler" {
  statement_id  = "AllowExecutionFromSNSFanIn"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.message_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.user_messages_topic.arn
}

resource "aws_lambda_permission" "allow_sns_to_delivery" {
  statement_id  = "AllowExecutionFromSNSFanOut"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delivery_func.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.response_topic.arn
}

# 8. Assinaturas (Subscriptions)
resource "aws_sns_topic_subscription" "handler_subscription" {
  topic_arn = aws_sns_topic.user_messages_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.message_handler.arn
}

resource "aws_sns_topic_subscription" "delivery_subscription" {
  topic_arn = aws_sns_topic.response_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.delivery_func.arn
}