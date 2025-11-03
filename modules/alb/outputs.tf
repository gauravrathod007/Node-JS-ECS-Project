output "alb_arn" {
  value = aws_lb.this.arn
}
output "alb_dns_name" {
  value = aws_lb.this.dns_name
}
output "target_group_arn" {
  value = aws_lb_target_group.this.arn
}
output "http_listener_arn" {
  description = "The ARN of the HTTP listener for the ALB"
  value       = aws_lb_listener.http.arn
}

