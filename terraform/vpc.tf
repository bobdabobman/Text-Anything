resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

variable "subnet_configs" {
  type = map(any)
  default = {
    "subnet-1" = { az = "us-east-1a", cidr = "10.0.1.0/24" }
    "subnet-2" = { az = "us-east-1b", cidr = "10.0.2.0/24" }
  }
}

resource "aws_subnet" "public_subnets" {
  for_each = var.subnet_configs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value["cidr"]
  availability_zone = each.value["az"]
  map_public_ip_on_launch = true

  tags = {
    Name = "${each.key}-public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-route-table-public"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_subnets" {
  for_each      = { for subnet in aws_subnet.public_subnets : subnet.id => subnet }
  subnet_id     = each.value.id
  route_table_id = aws_route_table.public.id
}
