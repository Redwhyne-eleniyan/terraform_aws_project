output "loadbalancerdns" {
  value = aws_alb.myalb.dns_name
}

output "aws_instance_public_ip" {
  value = aws_instance.server1.public_ip
}

output "aws_instance2_public_ip" {
    value = aws_instance.server2.public_ip
}