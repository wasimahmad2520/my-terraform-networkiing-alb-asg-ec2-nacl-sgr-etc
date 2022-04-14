
// TODO break public and private into separate AZs
data "aws_availability_zones" "available" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name                             = "${var.namespace}-vpc"
  cidr                             = "10.0.0.0/16"
  azs                              = data.aws_availability_zones.available.names
  private_subnets                  = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets                   = ["10.0.101.0/24", "10.0.102.0/24"]
  #assign_generated_ipv6_cidr_block = true
  create_database_subnet_group     = true
  enable_nat_gateway               = true
  single_nat_gateway               = true
}

/* creating NACL */

resource "aws_network_acl" "dmz" {
  vpc_id     =  module.vpc.vpc_id
  subnet_ids = [module.vpc.public_subnets[0]]
  tags ={
    name    = "nacl-terraform"
 
  }
}

# Allow flow from the vpc
/* resource "aws_network_acl_rule" "fromvpc" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 100
  egress         = false
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  lifecycle {
    ignore_changes = ["protocol"]
  }
} */

# Allow http internet access into the dmz
resource "aws_network_acl_rule" "http" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 200
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# Allow https internet access into the dmz
resource "aws_network_acl_rule" "https" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 300
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}



# Allow db internet access into the dmz
resource "aws_network_acl_rule" "mysq" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 400
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3306
  to_port        = 3306
}

# Allow ssh internet access into the dmz
resource "aws_network_acl_rule" "ssh" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 500
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}

# Allow all internet access into the dmz
/* resource "aws_network_acl_rule" "all" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 600
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65500
} */

resource "aws_network_acl_rule" "outbound" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 100
  egress         = true
  protocol       = -1
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
  lifecycle {
    ignore_changes = ["protocol"]
  }
}









// SG to allow SSH connections from anywhere
resource "aws_security_group" "allow_ssh_pub" {
  name        = "${var.namespace}-allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress =[
     {
    description = "SSH from the internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids=[]
    security_groups=[]
    self=false
  },
    {
    description = "HTTP from the internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids=[]
    security_groups=[]
    self=false
  },
  
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-allow_ssh_pub"
  }
}

// SG to onlly allow SSH connections from VPC public subnets
resource "aws_security_group" "allow_ssh_priv" {
  name        = "${var.namespace}-allow_ssh_priv"
  description = "Allow SSH inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH only from internal VPC clients"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
 
  }

  ingress {
    description = "DB Services VPC clients"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }


  /* ingress {
    description = "DB Services VPC clients"
    from_port   = 1
    to_port     = 60000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  } */
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.namespace}-allow_ssh_priv"
  }
}






