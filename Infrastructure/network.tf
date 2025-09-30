# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-VPC"
    Environment = var.environment
  }
}

# Public Subnets (one per AZ)
resource "aws_subnet" "public_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public_subnet-${var.availability_zones[count.index]}"
    Environment = var.environment
  }
}

# Private Subnets (one per AZ)
resource "aws_subnet" "private_subnets" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-private_subnet-${var.availability_zones[count.index]}"
    Environment = var.environment
  }
}


# Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-internet-gateway"
    Environment = var.environment
  }
}

# NAT Gateway and Elastic IP (one per AZ)
resource "aws_eip" "nat_elastic_ips" {
    count = length(var.availability_zones)

    tags = {
      Name        = "${var.environment}-nat-elastic-ip-${var.availability_zones[count.index]}"
      Environment = var.environment
    }
}

resource "aws_nat_gateway" "nat_gateways" {
  count         = length(var.availability_zones)  
  allocation_id = aws_eip.nat_elastic_ips[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id
  depends_on    = [ aws_internet_gateway.internet_gateway ]

  tags = {
    Name        = "${var.environment}-nat-gateway-${var.availability_zones[count.index]}"
    Environment = var.environment
  }
}

# Public Route Table and Association
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}

resource "aws_route" "public_route_to_internet" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = var.public_destination_cidr
  gateway_id             = aws_internet_gateway.internet_gateway.id 
}

resource "aws_route_table_association" "public_subnets_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Private Route Table and Association (one per AZ)
resource "aws_route_table" "private_route_tables" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.environment}-private-route-table-${var.availability_zones[count.index]}"
    Environment = var.environment
  }
}

resource "aws_route" "private_route_to_nat" {
  count                 = length(var.availability_zones)
  route_table_id        = aws_route_table.private_route_tables[count.index].id
  destination_cidr_block = var.public_destination_cidr
  nat_gateway_id        = aws_nat_gateway.nat_gateways[count.index].id
}

resource "aws_route_table_association" "private_subnets_association" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_tables[count.index].id
}

# Endpoints
resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = concat([aws_route_table.public_route_table.id], aws_route_table.private_route_tables[*].id)

  tags = {
    Name        = "${var.environment}-s3-endpoint"
    Environment = var.environment
  }
}

# Bastion Host Security Group
resource "aws_security_group" "bastion_security_group" {
  name        = "${var.environment}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH from trusted IP range"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["${var.bastion_host_ssh_cidr}"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["${var.public_destination_cidr}"]
  }
  
  tags = {
    Name        = "${var.environment}-bastion-security-group"
    Environment = var.environment
  }
}