provider "aws" {
  region = "us-east-1"
}

# vpc
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

# public subnet
resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# internet gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}

# route table and its associations
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  # internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  # default local route is implicitly created
  # and cannot be specified
}

resource "aws_route_table_association" "subnet_rt" {
  subnet_id = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# security group for ec2
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ipv6" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol = "-1"
  cidr_ipv6 = "::/0"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv6 = "::/0"
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

# ssh key
resource "aws_key_pair" "ssh-key" {
  key_name = "tf-play-ssh"
  public_key = file("../tf-play-ssh-key.pub")
}

# ec2
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = [ "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*" ]
  }
  owners = ["099720109477"] # canonical
}

resource "aws_instance" "ec2" {
  ami = data.aws_ami.ubuntu.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.subnet.id
  security_groups = [ aws_security_group.ec2_sg.id ]
  key_name = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
}