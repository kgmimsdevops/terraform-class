provider "aws" {
    
    region     = "ap-south-1"
    access_key = "Access Key"
    secret_key = "Secret Key"

}

variable "instance_type" {
  default = "t2.micro"
}

resource "aws_vpc" "tf_vpc_1" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tf_vpc_1"
  }
}

resource "aws_subnet" "tf_sub_1" {
  vpc_id     = aws_vpc.tf_vpc_1.id
  cidr_block = "192.168.1.0/24"

  tags = {
    Name = "tf_sub_1"
  }
}

resource "aws_internet_gateway" "tf_gw_1" {
  vpc_id = aws_vpc.tf_vpc_1.id

  tags = {
    Name = "tf_gw_1"
  }
}

resource "aws_default_route_table" "tf_drt" {
  default_route_table_id = aws_vpc.tf_vpc_1.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_gw_1.id
  }


  tags = {
    Name = "tf_drt"
  }
}

resource "aws_security_group" "tf_sg_1" {
  vpc_id      = aws_vpc.tf_vpc_1.id

  tags = {
    Name = "tf_sg_1"
  }
}


resource "aws_security_group_rule" "allow_ssh" {

 type              = "ingress"
 from_port         = 22
 to_port           = 22
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.tf_sg_1.id

}

resource "aws_security_group_rule" "allow_ICMP" {

 type              = "ingress"
 from_port         = 0
 to_port           = 0
 protocol          = "icmp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.tf_sg_1.id

}

resource "aws_security_group_rule" "allow_http" {

 type              = "ingress"
 from_port         = 80
 to_port           = 80
 protocol          = "tcp"
 cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = aws_security_group.tf_sg_1.id

}

resource "aws_key_pair" "tf_key_1" {
  key_name   = "tf_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAy9Fqbkne0yu/QdHYUifv31SOOLX3rB/JaTISFiL/VqsRV05XdWfRaFoO46f1Bdc5qXiAZWY2l8OLLWlbar5P7KAZfMRfqtMC0d1npGCVkME8TY1FXoU2vX3OnC2pAGSFr8fPdRUKU+QElD8WZlv0+21WTlj+tugsNzHziNS/5X/c+lWBfJEg+/et3Rjqjo6Ve/9lllhOibwzTlmZG6hAN0oQhKlr3BzoQoFC2JZXshzeu0nbzjIyM9NnYvC53cjJUhwWFSojP9VKhld/U+ryFDLWiKCnVABpRibjevvwkOyPsaKef+XvrbvEM3X6WvxtwqtM75aFJDUigSSlNXnOt2mPc9RT8jPxS4D56rdJY5JsKJZl61TiHL9rnG6lSP18CQGBDyjFzwyvVtFyb7D0eeo0CxDCZPJR2zSMGOoIjc8H3hPKHoRMGCingf+yeoMnGH8h8bXogWsAuxkAkmgOlaljX8v6ghIoqIbiwdztWP+77wv3AHlXWm34ORJ9w9c= sathyabharathi@LAPTOP-H1H6JU6H"
}


data "aws_ami" "tf_ami" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-2.0.*.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "tf_demo_1" {
  ami           = data.aws_ami.tf_ami.id
  instance_type = var.instance_type
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.tf_sg_1.id]
  key_name = "tf_key"
  subnet_id = aws_subnet.tf_sub_1.id

  tags = {
    Name = "tf_demo_1"
  }
}