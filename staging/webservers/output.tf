# Step 10 - Add output variables
output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "stage_alb" {
  value = aws_lb.stg_alb.dns_name
}