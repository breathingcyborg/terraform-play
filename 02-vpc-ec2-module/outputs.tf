output "instance_ip" {
    description = "Public ipv4 of instance created"
    value = aws_instance.ec2.public_ip
}