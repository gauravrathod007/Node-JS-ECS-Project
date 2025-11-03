variable "name_prefix" {}
variable "public_subnet_ids" { type = list(string) }
variable "alb_sg_id" {}
variable "vpc_id" {}
variable "container_port" {
  type    = number
  default = 3000
}
