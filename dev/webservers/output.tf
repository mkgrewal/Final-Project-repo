# Step 10 - Add output variables
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "tcw_alb" {
  value = aws_lb.tcw_alb_dev.dns_name
}

