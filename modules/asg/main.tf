
/* Creating Auto Scalling  */


/* Step 1:- Launch Configuration  */
resource "aws_launch_configuration" "web" {
  name_prefix = var.lc_prefix
  image_id = var.my_ami.id
  instance_type = var.lc_instance_type
  depends_on = [
    var.my_ami,
    var.demosg1,
    var.alb
  ]
    key_name                    = var.key_name
  /* key_name = "tests" */
  security_groups = [ "${var.demosg1.id}" ]
  associate_public_ip_address = true
  user_data = "${file(var.lc_user_data)}"
  lifecycle {
  create_before_destroy = true
}
}




/* Step 2:- Creating Auto Scalling Group */

resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.web.name}-asg"
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_size
  max_size             = var.asg_max_size

  health_check_type    = var.asg_health_check_type
  depends_on = [
    /* aws_lb.alb, */
    aws_launch_configuration.web
  ]
launch_configuration = "${aws_launch_configuration.web.name}"
enabled_metrics = [
  "GroupMinSize",
  "GroupMaxSize",
  "GroupDesiredCapacity",
  "GroupInServiceInstances",
  "GroupTotalInstances"
]
metrics_granularity = "1Minute"
vpc_zone_identifier  = [
  var.vpc.public_subnets[0]
]
# Required to redeploy without an outage.
lifecycle {
  create_before_destroy = true
}
tag {
  key                 = "Name"
  value               = var.asg_instance_name
  propagate_at_launch = true
}
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn    = var.lb_target.arn
}



/* output "ALB_DNS" {
  description = "ALB_DNS"
  value = aws_lb.alb.dns_name
} */
