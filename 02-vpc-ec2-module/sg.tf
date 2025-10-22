resource "aws_security_group" "ec2_sg" {
    vpc_id = module.vpc.vpc_id
}

resource "aws_vpc_security_group_egress_rule" "allow_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_egress_rule" "allow_ipv6" {
  security_group_id = aws_security_group.ec2_sg.id
  cidr_ipv6 = "::/0"
  ip_protocol = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol = "tcp"
  cidr_ipv4 = "0.0.0.0/0"
  # from and to are not for incoming and outgoing, its port ranage start / end
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  security_group_id = aws_security_group.ec2_sg.id
  ip_protocol = "tcp"
  cidr_ipv6 = "::/0"
  # from and to are not for incoming and outgoing, its port ranage start / end
  from_port = 22
  to_port = 22
}
