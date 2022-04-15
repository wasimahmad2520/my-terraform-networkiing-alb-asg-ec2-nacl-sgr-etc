
/* Creating AMI from public instnace */
resource "aws_ami_from_instance" "my_ami" {
  name               = "Web-Server-AMI"
  source_instance_id =  var.ec2_instance.id 
  depends_on = [
    var.ec2_instance 
  ]
  tags = {
    "Name" = "Web-Server-AMI"
  }
}




/* creating ELB */
/* https://github.com/DhruvinSoni30/Terrafrom-ELB-ASG */



# Creating Security Group for ELB
resource "aws_security_group" "demosg1" {
  name        = "Web-ELB SG"
  description = "Web-ELB SG Module"
  vpc_id      = var.vpc.vpc_id

# Inbound Rules
# HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
# Outbound Rules
# Internet access to anywhere
egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}



/* 2 step */





resource "aws_lb" "alb" {
  name = "${var.prefix}${var.namespace}"
  internal                   = false
  load_balancer_type         = var.load_balancer_type
  security_groups            = [ "${aws_security_group.demosg1.id}"]
  subnets                    = [ var.vpc.public_subnets[0],var.vpc.public_subnets[1]]
  enable_deletion_protection = false
  
  depends_on = [
  aws_security_group.demosg1
]
 tags = {
    "Name" = var.alb_tag
  }
}

resource "aws_lb_target_group" "lb_target" {
  name_prefix = var.target_group_prefix
  port        = 80
  protocol    = var.target_group_protocol
  vpc_id      =  var.vpc.vpc_id
  depends_on = [
    aws_lb.alb
  ]
  

  health_check  {
    interval            = var.hc_interval
    healthy_threshold   = var.hc_healthy_threshold
    unhealthy_threshold = var.hc_unhealthy_threshold
    timeout             = var.hc_timeout
    path                = var.hc_path
    port                = var.hc_port
    matcher             = var.hc_matcher
  }

 tags = {
    "Name" = var.target_group_tag
  }
}


/* resource "aws_lb_target_group_attachment" "tar_attach" {
  target_group_arn = aws_lb_target_group.lb_target.arn
  target_id        = aws_instance.ec2_public.id
  port             = 80
} */




resource "aws_lb_listener" "lb_listener" {
  count = 1

  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"
  depends_on = [
    aws_lb.alb
  ]
  default_action  {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_target.arn}"
  }
}

resource "aws_lb_listener" "lb_listener_redirect_http" {
  count = 0

  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "80"
  protocol          = "HTTP"
depends_on = [
  aws_lb.alb
]
  default_action  {
    type = "redirect"

    redirect  {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "lb_listener_https" {
  count =0

  load_balancer_arn = "${aws_lb.alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = ""
  depends_on = [
    aws_lb.alb
  ]
  default_action  {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb_target.arn}"
  }
}










