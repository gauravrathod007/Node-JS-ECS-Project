variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "container_image" {
  description = "ECR image URI for the container"
  type        = string
}
