variable "name_prefix" {}
variable "container_image" {}
variable "container_port" {
  type    = number
  default = 3000
}
variable "task_cpu" { default = "256" }
variable "task_memory" { default = "512" }
variable "execution_role_arn" {}
variable "task_role_arn" {}
variable "subnet_ids" { type = list(string) }
variable "ecs_sg_id" {}
variable "target_group_arn" {}
variable "listener_arn" {}
variable "desired_count" {
  type    = number
  default = 1
}
variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "host_header" {
  type    = string
  default = ""
}

