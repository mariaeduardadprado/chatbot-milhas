resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.name}-ecsTaskExecutionRole-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.name}-ecsTaskRole-${var.environment}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.name}-task-${var.environment}"
  retention_in_days = 14
  tags = {
    Name        = "${var.name}-task-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_iam_policy" "ecs_bedrock_policy" {
  name        = "ECSAppBedrockAccess"
  description = "Permite que o agente no ECS chame o Claude 3 no Bedrock"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream",
          "bedrock:Converse"
        ]
        Effect   = "Allow"
        Resource = "*" 
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_bedrock_attachment" {
  # Certifique-se que este nome coincide com o nome da role no seu código
  role = aws_iam_role.ecs_task_role.name 
  policy_arn = aws_iam_policy.ecs_bedrock_policy.arn
}

# 1. Política de permissão para publicar no SNS
resource "aws_iam_policy" "ecs_sns_publish_policy" {
  name        = "ECS-SNS-Publish-Policy"
  description = "Permite que o Agente publique no tópico de Fan-out"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sns:Publish"
        Effect   = "Allow"
        # Garante que ele só pode publicar no tópico de resposta
        Resource = var.response_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_sns_attachment" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_sns_publish_policy.arn
}

resource "aws_ecs_task_definition" "main" {
  family                   = "${var.name}-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  container_definitions = jsonencode([{
    name        = "${var.name}-container-${var.environment}"
    image       = "${var.container_image}:latest"
    essential   = true

    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.container_port
    }]

    environment = [
  {
    name  = "RESPONSE_TOPIC_ARN"
    value = var.response_topic_arn
  }
]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
  }])


  tags = {
    Name        = "${var.name}-task-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${var.name}-cluster-${var.environment}"
  tags = {
    Name        = "${var.name}-cluster-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_ecs_service" "main" {
  name                               = "${var.name}-service-${var.environment}"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = var.service_desired_count
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200
  health_check_grace_period_seconds  = 120
  launch_type                        = "FARGATE"
  scheduling_strategy                = "REPLICA"

  network_configuration {
    security_groups  = var.ecs_service_security_groups
    subnets          = var.ecs_subnets_id
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.aws_alb_target_group_arn
    container_name   = "${var.name}-container-${var.environment}"
    container_port   = var.container_port
  }

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }
}
