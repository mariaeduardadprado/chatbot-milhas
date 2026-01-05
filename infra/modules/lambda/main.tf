# 1. Zips das Lambdas
data "archive_file" "lambda_handler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-handler.py"
  output_path = "${path.module}/lambda_handler_payload.zip"
}

data "archive_file" "lambda_delivery_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda-delivery.py"
  output_path = "${path.module}/lambda_delivery_payload.zip"
}

# 2. IAM Role da Lambda
resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.name}-lambda-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

# 3. Lambda Message Handler (Fan-in)
resource "aws_lambda_function" "message_handler" {
  filename      = data.archive_file.lambda_handler_zip.output_path
  function_name = "${var.name}-message-handler-${var.environment}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda-handler.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      ECS_ENDPOINT       = var.ecs_endpoint
      RESPONSE_TOPIC_ARN = var.response_topic_arn
    }
  }

  source_code_hash = data.archive_file.lambda_handler_zip.output_base64sha256
}

# 4. Lambda Delivery (Fan-out)
resource "aws_lambda_function" "delivery_func" {
  filename      = data.archive_file.lambda_delivery_zip.output_path
  function_name = "${var.name}-delivery-${var.environment}"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "lambda-delivery.lambda_handler"
  runtime       = "python3.9"

  source_code_hash = data.archive_file.lambda_delivery_zip.output_base64sha256
}

# 5. IAM Policy — SNS Publish + Logs
resource "aws_iam_policy" "lambda_sns_publish" {
  name = "${var.name}-lambda-sns-publish-${var.environment}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sns:Publish"
        Resource = var.response_topic_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attach" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}

# 6. Permissões SNS → Lambda
resource "aws_lambda_permission" "allow_sns_to_handler" {
  statement_id  = "AllowExecutionFromSNSFanIn"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.message_handler.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.user_messages_topic_arn
}

resource "aws_lambda_permission" "allow_sns_to_delivery" {
  statement_id  = "AllowExecutionFromSNSFanOut"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delivery_func.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.response_topic_arn
}

# 7. Subscriptions SNS → Lambda
resource "aws_sns_topic_subscription" "handler_subscription" {
  topic_arn = var.user_messages_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.message_handler.arn

  depends_on = [
    aws_lambda_permission.allow_sns_to_handler
  ]
}

resource "aws_sns_topic_subscription" "delivery_subscription" {
  topic_arn = var.response_topic_arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.delivery_func.arn

  depends_on = [
    aws_lambda_permission.allow_sns_to_delivery
  ]
}
