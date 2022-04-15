output "my_ami" {
  value = aws_ami_from_instance.my_ami
}

output "demosg1" {
  value = aws_security_group.demosg1
}

output "alb" {
  value = aws_lb.alb
}

output "lb_target" {
  value = aws_lb_target_group.lb_target
}