output "alb_arn" {
  description = "ARN del ALB — consumido por: ecs-fargate"
  value       = aws_lb.main.arn
}

output "alb_dns_name" {
  description = "DNS del ALB — consumido por: api-gateway, cloudfront"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "Zone ID del ALB — consumido por: route53"
  value       = aws_lb.main.zone_id
}

output "api_target_group_arn" {
  description = "ARN del target group API — consumido por: ecs-fargate"
  value       = aws_lb_target_group.api.arn
}

output "web_target_group_arn" {
  description = "ARN del target group Web — consumido por: ecs-fargate"
  value       = aws_lb_target_group.web.arn
}

output "http_listener_arn" {
  description = "ARN del listener HTTP"
  value       = aws_lb_listener.http.arn
}