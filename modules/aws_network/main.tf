# Step 1 - Define the provider
provider "aws" {
  region = "us-east-1"
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}


# Adding SSH key to Amazon EC2
resource "aws_key_pair" "web_key" {
  key_name   = var.prefix
  public_key = file("${var.prefix}.pub")
}


# Create a new VPC 
resource "aws_vpc" "dev_vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-vpc"
    }
  )
}


# Add provisioning of the public subnetin the default VPC
resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index}"
    }
  )
}

# Add provisioning of the private subnets in the custom VPC
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.dev_vpc.id
  count             = length(var.private_cidr_blocks)
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index}"
      Tier = "Private"
    }
  )
}


# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.dev_vpc.id

  tags = merge(var.default_tags,
    {
      "Name" = "${var.prefix}-igw"
    }
  )
}

# Route table to route add default gateway pointing to Internet Gateway (IGW)
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.prefix}-route-public-route_table"
  }
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}

#Create NAT GW
resource "aws_nat_gateway" "nat-gw" {
  #count          = length(aws_subnet.public_subnet[*].id)
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.public_subnet[0].id

  tags = {
    Name = "${var.prefix}-natgw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

# Create elastic IP for NAT GW
resource "aws_eip" "nat-eip" {
  vpc = true
  tags = {
    Name = "${var.prefix}-natgw"
  }

}

# Route table to route add default gateway pointing to NAT Gateway (NATGW)
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.dev_vpc.id
  tags = {
    Name = "${var.prefix}-route-private-route_table",
    Tier = "Private"
  }
}

# Add route to NAT GW if we created public subnets
resource "aws_route" "private_route" {
  #count = 3
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat-gw.id
}

# Associate subnets with the custom route table
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}


/*#Load Balancer
resource "aws_elb" "web_elb" {
  tags = merge(
    var.default_tags, {
      Name = "${var.prefix}-elb"
    }
  )
  security_groups = [
    "${aws_security_group.demosg1.id}"
  ]
  subnets = [
    "${aws_subnet.public_subnet[1].id}",
    "${aws_subnet.public_subnet[2].id}",
    "${aws_subnet.public_subnet[0].id}"
  ]
  cross_zone_load_balancing = true
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
}*/







