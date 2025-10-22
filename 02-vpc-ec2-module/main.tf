provider "aws" {
    region = "us-east-1"
}

# ssh key
resource "aws_key_pair" "ssh-key" {
  key_name = "tf-play-ssh"
  public_key = file("../tf-play-ssh-key.pub")
}

# ubuntu
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

  subnet_id = module.vpc.public_subnets[0]
  security_groups = [ aws_security_group.ec2_sg.id ]
  key_name = aws_key_pair.ssh-key.key_name
  associate_public_ip_address = true
}