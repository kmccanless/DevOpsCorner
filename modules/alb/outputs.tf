output "lb_target_group_arn" {
  value = aws_lb_target_group.lb_tg.arn
}
output "lb_sg_id" {
  value = aws_security_group.lb_access_sg.id
}