
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
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.vpc.public_subnets[0]
  vpc_security_group_ids      = [var.sg_pub_id]
  security_groups = []
   user_data = "${file(var.public_instance_user_data)}"
 
  tags = {
    "Name" = "${var.namespace}${var.public_instance_suffix}"
  }

  # Copies the ssh key file to home dir
  provisioner "file" {
    source      = "./${var.key_name}.pem"
    destination = "${var.key_placement_path}${var.key_name}.pem"

    connection {
      type        = "ssh"
      user        = var.instance_user_name
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }
  }
  
  //chmod key 400 on EC2 instance
  provisioner "remote-exec" {
    inline = ["chmod 400 ~/${var.key_name}.pem"]

    connection {
      type        = "ssh"
      user        = var.instance_user_name
      private_key = file("${var.key_name}.pem")
      host        = self.public_ip
    }

  }

}
// Configure the EC2 instance in a private subnet
resource "aws_instance" "ec2_private" {
  ami                         =  var.os-platform
  associate_public_ip_address = false
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = var.vpc.private_subnets[0]
  vpc_security_group_ids      = [var.sg_priv_id]
  private_ip                  = var.db_server_private_ip
  user_data = "${file(var.db_server_user_data)}"

  

  tags = {
    "Name" = "${var.namespace}${var.db_server_suffix}"
  }

}


























