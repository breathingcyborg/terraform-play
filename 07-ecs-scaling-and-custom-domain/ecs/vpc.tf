# --------------------------------------------------------
# VPC with subnets
# --------------------------------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = "10.0.0.0/16"
  enable_dns_hostnames             = true
  enable_dns_support               = true
  assign_generated_ipv6_cidr_block = true
}

resource "aws_subnet" "subnet_1" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = "10.0.1.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 0)
  availability_zone               = "us-east-1a"
  assign_ipv6_address_on_creation = true
}

resource "aws_subnet" "subnet_2" {
  vpc_id                          = aws_vpc.vpc.id
  cidr_block                      = "10.0.2.0/24"
  ipv6_cidr_block                 = cidrsubnet(aws_vpc.vpc.ipv6_cidr_block, 8, 1)
  availability_zone               = "us-east-1b"
  assign_ipv6_address_on_creation = true
}

# --------------------------------------------------------
# Route tables for these subnets
# --------------------------------------------------------
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.ig.id
  }
}

resource "aws_route_table_association" "subnet_1_rt" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.subnet_1.id
}

resource "aws_route_table_association" "subnet_2_rt" {
  route_table_id = aws_route_table.rt.id
  subnet_id      = aws_subnet.subnet_2.id
}

# --------------------------------------------------------
# Security group for ec2 instance, that has ecs agent
# - it communicates to ecs control plane via internet
# - so we allow all outgoing traffic
# --------------------------------------------------------
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_egress_rule" "ec2_allow_all_outgoing_ipv4" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_vpc_security_group_egress_rule" "ec2_allow_all_outgoing_ipv6" {
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv4" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = aws_security_group.ec2_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_ipv6" {
  cidr_ipv6         = "::/0"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  security_group_id = aws_security_group.ec2_sg.id
}

# --------------------------------------------------------
# Security group for task / our container
# - our container runs in awsvpc network mode
# - so it gets its on network interface (eni)
# - we allow all outgoing traffic
# - we allow traffic from load balancer
# --------------------------------------------------------
resource "aws_security_group" "container_sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "container_allow_load_balancer" {
  referenced_security_group_id = aws_security_group.lb_sg.id
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.container_sg.id
  from_port                    = 3000
  to_port                      = 3000
}

resource "aws_vpc_security_group_egress_rule" "container_allow_all_outgoing_ipv4" {
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.container_sg.id
}

resource "aws_vpc_security_group_egress_rule" "container_allow_all_outgoing_ipv6" {
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
  security_group_id = aws_security_group.container_sg.id
}

# --------------------------------------------------------
# Security group for load balancer that 
# forwards traffic to our task/container
# - we allow incoming traffic on ports 80 and 443
# - we allow outgoing traffic to container
# --------------------------------------------------------
resource "aws_security_group" "lb_sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "lb_http_ipv4" {
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "lb_http_ipv6" {
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv6         = "::/0"
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "lb_https_ipv4" {
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv4         = "0.0.0.0/0"
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "lb_https_ipv6" {
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  cidr_ipv6         = "::/0"
  security_group_id = aws_security_group.lb_sg.id
}

resource "aws_vpc_security_group_egress_rule" "lb_allow_to_container" {
  ip_protocol                  = "tcp"
  from_port                    = 3000
  to_port                      = 3000
  security_group_id            = aws_security_group.lb_sg.id
  referenced_security_group_id = aws_security_group.container_sg.id
}