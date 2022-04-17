

#----------------------------------------------------------
# ACS730 - Week 3 - Terraform Introduction
#
# Build EC2 Instances
#
#----------------------------------------------------------

#  Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Use remote state to retrieve the data
data "terraform_remote_state" "prod-network" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "prod-acs730"                   // Bucket from where to GET Terraform State
    key    = "dev-network/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                     // Region where bucket created
  }
}


# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(module.globalvars.default_tags, { "env" = var.env })
  prefix       = module.globalvars.prefix
  name_prefix  = local.prefix
}

# Retrieve global variables from the Terraform module
module "globalvars" {
  source = "../../modules/globalvars"
}

# Webserver deployment
resource "aws_instance" "prod_vm1" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.prod_key.key_name
  subnet_id                   = data.terraform_remote_state.prod-network.outputs.private_subnet_id[0]
  security_groups             = [aws_security_group.prod_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Prod-Linux1"
    }
  )
}


# Webserver deployment
resource "aws_instance" "prod_vm2" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.prod_key.key_name
  subnet_id                   = data.terraform_remote_state.prod-network.outputs.private_subnet_id[1]
  security_groups             = [aws_security_group.prod_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  #   user_data                   = <<EOF
  #     #!/bin/bash
  #     yum -y update
  #     yum -y install httpd
  #     echo "<h1>Welcome to ACS730 Week 4!"  >  /var/www/html/index.html
  #     # sudo systemctl httpd start
  #     # sudo systemctl httpd enable
  #     sudo systemctl start httpd
  #     sudo systemctl enable httpd
  # EOF

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Prod-Linux2"
    }
  )
}


# Webserver deployment
resource "aws_instance" "prod_vm3" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.prod_key.key_name
  subnet_id                   = data.terraform_remote_state.prod-network.outputs.private_subnet_id[2]
  security_groups             = [aws_security_group.prod_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )

  /*user_data                   = <<EOF
    !/bin/bash
    yum -y update
       yum -y install httpd
       echo "<h1>Welcome to ACS730 Week 4!"  >  /var/www/html/index.html
       #sudo systemctl httpd start
       #sudo systemctl httpd enable
       sudo systemctl start httpd
       sudo systemctl enable httpd
  EOF*/

  root_block_device {
    encrypted = var.env == "prod" ? true : false
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-Prod-Linux3"
    }
  )
}



# Adding SSH key to Amazon EC2
resource "aws_key_pair" "prod_key" {
  key_name   = local.name_prefix
  public_key = file("${var.prefix}.pub")
}


#Security Group
resource "aws_security_group" "prod_sg" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.prod-network.outputs.vpc_id



  ingress {
    description      = "HTTP from everywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }



  ingress {
    description      = "SSH from everywhere"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }



  tags = merge(local.default_tags,
    {
      "Name" = "${var.prefix}-sg"
    }
  )
}


# Bastion deployment
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = lookup(var.instance_type, var.env)
  key_name                    = aws_key_pair.prod_key.key_name
  subnet_id                   = data.terraform_remote_state.prod-network.outputs.public_subnet_ids[1]
  security_groups             = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true


  lifecycle {
    create_before_destroy = true
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion"
    }
  )
}

# Security Group for Bastion host
resource "aws_security_group" "bastion_sg" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.prod-network.outputs.vpc_id

  ingress {
    description      = "SSH from private IP of CLoud9 machine"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.my_private_ip}/32", "${var.my_public_ip}/32"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "SSH from private IP of CLoud9 machine"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["${var.my_private_ip}/32", "${var.my_public_ip}/32"]
    ipv6_cidr_blocks = ["::/0"]
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "${local.name_prefix}-bastion-sg"
    }
  )
}



###Launch Configuration

resource "aws_launch_configuration" "prod_launchconfig" {
  name_prefix                 = "web-"
  image_id                    = "ami-03ededff12e34e59e"
  instance_type               = "t2.micro"
  key_name                    = "Assignment2"
  security_groups             = ["${aws_security_group.prod_sg_alb2.id}"]
  associate_public_ip_address = true
  user_data = templatefile("${path.module}/install_httpd.sh",
    {
      env    = upper(var.env),
      prefix = upper(local.prefix)
    }
  )


  lifecycle {
    create_before_destroy = true
  }
}


###Auto Scaling Group

resource "aws_autoscaling_group" "prod_asg" {
  name             = "${aws_launch_configuration.prod_launchconfig.name}-asg"
  min_size         = 1
  desired_capacity = 1
  max_size         = 4

  health_check_type = "ELB"


  launch_configuration = aws_launch_configuration.prod_launchconfig.name
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTotalInstances"
  ]
  metrics_granularity = "1Minute"
  vpc_zone_identifier = [
    data.terraform_remote_state.prod-network.outputs.private_subnet_id[0],
    data.terraform_remote_state.prod-network.outputs.private_subnet_id[1],
    data.terraform_remote_state.prod-network.outputs.private_subnet_id[2]
  ]

  target_group_arns = ["${aws_lb_target_group.prod_tg.id}"]

  # Required to redeploy without an outage.
  lifecycle {
    create_before_destroy = true
  }
  tag {
    key                 = "Name"
    value               = "web"
    propagate_at_launch = true
  }
}



####Auto scaling policy



resource "aws_autoscaling_policy" "web_policy_up" {
  name                   = "web_policy_up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.prod_asg.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name          = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "70"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.prod_asg.name}"
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = ["${aws_autoscaling_policy.web_policy_up.arn}"]
}
resource "aws_autoscaling_policy" "web_policy_down" {
  name                   = "web_policy_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.prod_asg.name
}
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name          = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "30"
  dimensions = {
    AutoScalingGroupName = "${aws_autoscaling_group.prod_asg.name}"
  }
  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions     = ["${aws_autoscaling_policy.web_policy_down.arn}"]
}

# Creating Security Group for ELB
resource "aws_security_group" "prod_sg_alb2" {
  name        = "Prod Security Group2"
  description = "prod Module"
  vpc_id      = data.terraform_remote_state.prod-network.outputs.vpc_id
  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating Security Group for Load Balancersg
resource "aws_security_group" "prod_sg_alb1" {
  name        = "Prod Security Group"
  description = "Prod Module"
  vpc_id      = data.terraform_remote_state.prod-network.outputs.vpc_id
  # Inbound Rules
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # HTTPS access from anywhere
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Outbound Rules
  # Internet access to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



#Target Group
resource "aws_lb_target_group" "prod_tg" {
  name     = "tcw-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.prod-network.outputs.vpc_id


}


#Crearting Load Balancer
resource "aws_lb" "prod_alb" {
  name               = "prod-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.prod_sg_alb1.id}"]

  # At least two subnets on different AZ must be specified

  subnets = [
    data.terraform_remote_state.prod-network.outputs.public_subnet_ids[0],
    data.terraform_remote_state.prod-network.outputs.public_subnet_ids[1],
    data.terraform_remote_state.prod-network.outputs.public_subnet_ids[2]
  ]

  enable_deletion_protection = false
  tags = {
    Environment = "prod"
  }
}


#Listener 
resource "aws_lb_listener" "alb_forward_listener" {
  load_balancer_arn = aws_lb.prod_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_tg.arn
  }
}


#Target group attachment
resource "aws_lb_target_group_attachment" "tg_prod1" {
  target_group_arn = aws_lb_target_group.prod_tg.arn
  target_id        = aws_instance.prod_vm1.id
  port             = 80

}

#Target group attachment
resource "aws_lb_target_group_attachment" "tg_prod2" {
  target_group_arn = aws_lb_target_group.prod_tg.arn
  target_id        = aws_instance.prod_vm2.id
  port             = 80

}

#Target group attachment
resource "aws_lb_target_group_attachment" "tg_prod3" {
  target_group_arn = aws_lb_target_group.prod_tg.arn
  target_id        = aws_instance.prod_vm3.id
  port             = 80

}




