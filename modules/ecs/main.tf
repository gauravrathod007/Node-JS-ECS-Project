resource "aws_ecs_cluster" "this" {
  name = "${var.name_prefix}-cluster"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.name_prefix}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.name_prefix}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.task_cpu    # e.g. "256"
  memory                   = var.task_memory # e.g. "512"
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = var.task_role_arn

  container_definitions = jsonencode([
    {
      name      = "hello-node"
      image     = var.container_image
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "hello-node"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.name_prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.this.arn

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [var.ecs_sg_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "hello-node"
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener_rule.this
  ]
}

# Optional: create a listener rule to route traffic - for simple setups the default listener forwards to the TG already.
resource "aws_lb_listener_rule" "this" {
  listener_arn = var.listener_arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }
  condition {
    host_header {
      values = [var.host_header == "" ? "${var.name_prefix}.*" : var.host_header]
    }
  }
}
