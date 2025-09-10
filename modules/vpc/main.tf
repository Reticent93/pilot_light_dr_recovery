resource "aws_vpc" "primary" {
    cidr_block            = var.vpc_cidr
    enable_dns_support    = true
    enable_dns_hostnames  = true

    tags = {
        Name = var.project_name
    }
}


resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id = var.vpc_id
  cidr_block = var.public_subnet_cidrs[count.index]

    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project_name}-public-subnet-${count.index + 1}"
        type = "public"
    }
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id = var.vpc_id
  cidr_block = var.private_subnet_cidrs[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
    type = "private"
  }
}


resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.primary.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_nat_gateway" "main" {
  subnet_id = aws_subnet.public[0].id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.primary.id

  route {
    cidr_block = var.public_route_table_id
    gateway_id = var.igw_id
    }
    tags = {
        Name = "${var.project_name}-public-rt"

    }
}


resource "aws_route_table_association" "private" {
  route_table_id = var.private_route_table_id
    subnet_id = aws_subnet.private[count.index].id
}
