output "alb_url" {
  value = aws_lb.ecs_alb.dns_name
}

# output "sg_alb_id" {
#     value = aws_security_group.lb.id
# }