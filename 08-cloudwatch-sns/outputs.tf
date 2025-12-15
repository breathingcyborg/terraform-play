output "ec2_ipv6" {
  value = aws_instance.ec2.ipv6_addresses[0]
}