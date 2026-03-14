locals {
  name_prefix = "${var.project_name}-${var.environment}"

  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.base_tags, { Name = "${local.name_prefix}-vpc" })
}

data "aws_availability_zones" "available_zones" {
  state = "available"
}

# Public subnet 1
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_1
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true
  tags                    = merge(local.base_tags, { Name = "${local.name_prefix}-public-subnet-1" })
}

# Public subnet 2
resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnet_cidr_2
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = true
  tags                    = merge(local.base_tags, { Name = "${local.name_prefix}-public-subnet-2" })
}

# Private subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr_1
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false
  tags                    = merge(local.base_tags, { Name = "${local.name_prefix}-private-subnet-1" })
}

# Private subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.private_subnet_cidr_2
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false
  tags                    = merge(local.base_tags, { Name = "${local.name_prefix}-private-subnet-2" })
}

# DB subnet 1
resource "aws_subnet" "db_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.db_subnet_cidr_1
  availability_zone       = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = false
  tags                    = merge(local.base_tags, { Name = "${local.name_prefix}-db-subnet-1" })
}

# DB subnet 2
resource "aws_subnet" "db_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.db_subnet_cidr_2
  availability_zone       = data.aws_availability_zones.available_zones.names[1]
  map_public_ip_on_launch = false
  tags                    = merge(local.base_tags, { Name = "${local.name_prefix}-db-subnet-2" })
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags   = merge(local.base_tags, { Name = "${local.name_prefix}-igw" })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
  tags       = merge(local.base_tags, { Name = "${local.name_prefix}-nat-eip" })
}

# NAT Gateway (in public subnet 1)
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  depends_on    = [aws_internet_gateway.igw]
  tags          = merge(local.base_tags, { Name = "${local.name_prefix}-nat-gw" })
}

# Public route table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.base_tags, { Name = "${local.name_prefix}-public-rt" })
}

# Private route table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }
  tags = merge(local.base_tags, { Name = "${local.name_prefix}-private-rt" })
}

# Associate public subnet 1 with public route table
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate public subnet 2 with public route table
resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# Associate private subnet 1 with private route table
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

# Associate private subnet 2 with private route table
resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

# Public security group (web server / NGINX)
resource "aws_security_group" "public_sg" {
  name        = "${local.name_prefix}-public-sg"
  description = "Public SG for web server"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(local.base_tags, { Name = "${local.name_prefix}-public-sg" })
}

resource "aws_security_group_rule" "public_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.allowed_cidr]
  security_group_id = aws_security_group.public_sg.id
  description       = "SSH access"
}

resource "aws_security_group_rule" "public_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
  description       = "HTTP access"
}

resource "aws_security_group_rule" "public_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
  description       = "HTTPS access"
}

resource "aws_security_group_rule" "public_app" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
  description       = "App port access"
}

resource "aws_security_group_rule" "public_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public_sg.id
  description       = "Allow all outbound"
}

# Private security group (app server / Docker)
resource "aws_security_group" "private_sg" {
  name        = "${local.name_prefix}-private-sg"
  description = "Private SG for app server"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(local.base_tags, { Name = "${local.name_prefix}-private-sg" })
}

resource "aws_security_group_rule" "private_from_public" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  source_security_group_id = aws_security_group.public_sg.id
  security_group_id        = aws_security_group.private_sg.id
  description              = "Allow all traffic from public SG"
}
resource "aws_security_group_rule" "private_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.private_sg.id
  description       = "Allow all outbound"
}

# DB security group
resource "aws_security_group" "db_sg" {
  name        = "${local.name_prefix}-db-sg"
  description = "DB SG - allow MySQL from private SG"
  vpc_id      = aws_vpc.vpc.id
  tags        = merge(local.base_tags, { Name = "${local.name_prefix}-db-sg" })
}

resource "aws_security_group_rule" "private_to_db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.private_sg.id
  security_group_id        = aws_security_group.db_sg.id
  description              = "Allow app server to talk to DB"
}

resource "aws_security_group_rule" "db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.db_sg.id
  description       = "Allow all outbound"
}
# DB subnet group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${local.name_prefix}-db-subnet-group"
  subnet_ids = [aws_subnet.db_subnet_1.id, aws_subnet.db_subnet_2.id]
  tags       = merge(local.base_tags, { Name = "${local.name_prefix}-db-subnet-group" })
}