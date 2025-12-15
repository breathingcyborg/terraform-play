data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
  owners = ["099720109477"] # canonical
}

resource "aws_instance" "ec2" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.ubuntu.id

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = aws_subnet.subnet.id
  key_name               = aws_key_pair.ssh_key.key_name

  ipv6_address_count = 1
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "tf-play-ssh"
  public_key = file("../tf-play-ssh-key.pub")
}