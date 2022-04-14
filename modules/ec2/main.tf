
// Create aws_ami filter to pick up the ami available in your region
data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


// Configure the EC2 instance in a public subnet
resource "aws_instance" "ec2_public" {
  ami                         = var.os-platform
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  security_groups = []
   user_data = "${file("./modules/ec2/user_data_web_server.sh")}"

  tags = {
    "Name" = "${var.namespace}-EC2-PUBLIC"
  }

  # Copies the ssh key file to home dir
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "/home/ubuntu/${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }

}
// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
  ami                         =  var.os-platform
  associate_public_ip_address = false
  instance_type               = "t2.micro"
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[0]
  vpc_security_group_ids      = [var.sg_priv_id]
  private_ip                  = "10.0.1.22"
  user_data = "${file("./modules/ec2/user_data_db_server.sh")}"

  

  tags = {
    "Name" = "${var.namespace}-EC2-PRIVATE"
  }

}



/* Creating AMI from public instnace */
resource "aws_ami_from_instance" "my_ami" {
  name               = "Web-Server-AMI"
  source_instance_id = aws_instance.ec2_public.id
  depends_on = [
    aws_instance.ec2_public
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


/* resource "aws_elb" "web_elb" {
name = "Web-ELB-${var.namespace}"

security_groups = [
  "${aws_security_group.demosg1.id}"
]
subnets = [
  var.vpc.public_subnets[0]
]
depends_on = [
  aws_security_group.demosg1
]
cross_zone_load_balancing   = true
health_check {
  healthy_threshold = 2
  unhealthy_threshold = 2
  timeout = 3
  interval = 30
  target = "HTTP:80/"
}
listener {
  lb_port = 80
  lb_protocol = "http"
  instance_port = "80"
  instance_protocol = "http"
}
} */








resource "aws_lb" "alb" {
  name = "Web-ELB-${var.namespace}"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [ "${aws_security_group.demosg1.id}"]
  subnets                    = [ var.vpc.public_subnets[0],var.vpc.public_subnets[1]]
  enable_deletion_protection = false
  
  depends_on = [
  aws_security_group.demosg1
]
 tags = {
    "Name" = "ALB"
  }
}

resource "aws_lb_target_group" "lb_target" {
  name_prefix = "LB-TG-"
  port        = 80
  protocol    = "HTTP"
  vpc_id      =  var.vpc.vpc_id
  depends_on = [
    aws_lb.alb
  ]
  

  health_check  {
    interval            = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    path                = "/"
    port                = 80
    matcher             = "200"
  }

 tags = {
    "Name" = "ALB-Target-GR"
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

















/* Creating Auto Scalling  */


/* Step 1:- Launch Configuration  */
resource "aws_launch_configuration" "web" {
  name_prefix = "web-"
  image_id = aws_ami_from_instance.my_ami.id
  instance_type = "t2.micro"
  depends_on = [
    aws_ami_from_instance.my_ami,
    aws_security_group.demosg1,
    aws_lb.alb
  ]
    key_name                    = var.key_name
  /* key_name = "tests" */
  security_groups = [ "${aws_security_group.demosg1.id}" ]
  associate_public_ip_address = true
  user_data = "${file("./modules/ec2/user_data_web_server.sh")}"
lifecycle {
  create_before_destroy = true
}
}




/* Step 2:- Creating Auto Scalling Group */

resource "aws_autoscaling_group" "web" {
  name = "${aws_launch_configuration.web.name}-asg"
  min_size             = 2
  desired_capacity     = 3
  max_size             = 6

  health_check_type    = "ELB"
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
  value               = "ASG-Web-Server"
  propagate_at_launch = true
}
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.web.id
  lb_target_group_arn    = aws_lb_target_group.lb_target.arn
}



output "ALB_DNS" {
  description = "ALB_DNS"
  value = aws_lb.alb.dns_name
}


















