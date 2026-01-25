# VPC Outputs
output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

# Subnet Outputs
output "public_subnet_id" {
  description = "The ID of the created public subnet"
  value       = aws_subnet.public_subnet.id
}

output "public_subnet_cidr" {
  description = "CIDR block of the public subnet"
  value       = aws_subnet.public_subnet.cidr_block
}

output "public_subnet_az" {
  description = "Availability Zone of the public subnet"
  value       = aws_subnet.public_subnet.availability_zone
}

# EC2 Instance Outputs
output "ec2_instance_id" {
  description = "The ID of the created EC2 instance"
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip
  sensitive   = false
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.web.public_dns
}

output "ec2_instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.web.instance_state
}

output "ec2_instance_type" {
  description = "Type of the EC2 instance"
  value       = aws_instance.web.instance_type
}

# Security Group Outputs
output "security_group_id" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2_sg.id
}

output "security_group_name" {
  description = "The name of the EC2 security group"
  value       = aws_security_group.ec2_sg.name
}

# Connection Information
output "ssh_connection_string" {
  description = "SSH connection string to connect to the instance"
  value       = "ssh -i /path/to/${var.key_name}.pem ec2-user@${aws_instance.web.public_ip}"
}

output "web_url" {
  description = "URL to access the web server"
  value       = "http://${aws_instance.web.public_dns}"
}

# Private Subnet Outputs (conditional)
output "private_subnet_id" {
  description = "The ID of the created private subnet"
  value       = var.enable_private_subnet ? aws_subnet.private_subnet[0].id : null
}

output "private_subnet_cidr" {
  description = "CIDR block of the private subnet"
  value       = var.enable_private_subnet ? aws_subnet.private_subnet[0].cidr_block : null
}

output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = var.enable_private_subnet ? aws_nat_gateway.nat[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway"
  value       = var.enable_private_subnet ? aws_eip.nat_eip[0].public_ip : null
}
