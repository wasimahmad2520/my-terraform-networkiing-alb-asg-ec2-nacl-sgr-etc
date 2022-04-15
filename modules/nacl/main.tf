

/* creating NACL */
resource "aws_network_acl" "dmz" {
  vpc_id     =  var.vpc.vpc_id
  subnet_ids = [var.vpc.public_subnets[0]]
  tags ={
    name    = var.nacl_tag
 
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
resource "aws_network_acl_rule" "mysql" {
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
resource "aws_network_acl_rule" "all" {
  network_acl_id = "${aws_network_acl.dmz.id}"
  rule_number    = 600
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 65500
}


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



