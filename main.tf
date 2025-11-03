module "network" {
  source              = "./modules/network"
  name_prefix         = var.environment
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  container_port      = 3000
}

module "iam" {
  source      = "./modules/iam"
  name_prefix = var.environment
}

module "alb" {
  source            = "./modules/alb"
  name_prefix       = var.environment
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.network.alb_sg_id
  vpc_id            = module.network.vpc_id
  container_port    = 3000
}

module "ecs" {
  source             = "./modules/ecs"
  name_prefix        = var.environment
  container_image    = var.container_image # ECR image URI, e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com/hello-node:latest
  container_port     = 3000
  execution_role_arn = module.iam.ecs_task_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  subnet_ids         = module.network.public_subnet_ids
  ecs_sg_id          = module.network.ecs_sg_id
  target_group_arn   = module.alb.target_group_arn
  listener_arn       = module.alb.http_listener_arn # NOTE: in module we exposed alb_arn; better to create listener and pass ARN. Adjust per your final layout.
  aws_region         = var.aws_region
  desired_count      = 1
}
