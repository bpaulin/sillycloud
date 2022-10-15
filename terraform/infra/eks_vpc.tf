resource "aws_vpc" "sillykloud" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "sillykloud"
  }
}

# Subnets
# Internet Gateway for Public Subnet
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.sillykloud.id
}

# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.ig]
}

# NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.sillykloud-public1.id
}





# Routing tables to route traffic for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.sillykloud.id
}

# Routing tables to route traffic for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.sillykloud.id
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for NAT
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Route table associations for both Public & Private Subnets
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.sillykloud-public1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.sillykloud-public2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.sillykloud-private1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.sillykloud-private2.id
  route_table_id = aws_route_table.private.id
}




# Default Security Group of VPC
resource "aws_security_group" "default" {
  name        = "default-sg"
  description = "Default SG to alllow traffic from the VPC"
  vpc_id      = aws_vpc.sillykloud.id
  depends_on = [
    aws_vpc.sillykloud
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
}






data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "sillykloud-public1" {
  vpc_id                  = aws_vpc.sillykloud.id
  cidr_block              = "192.168.0.0/18"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "sillykloud-public1"
  }
}

resource "aws_subnet" "sillykloud-public2" {
  vpc_id                  = aws_vpc.sillykloud.id
  cidr_block              = "192.168.64.0/18"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "sillykloud-public2"
  }
}

resource "aws_subnet" "sillykloud-private1" {
  vpc_id            = aws_vpc.sillykloud.id
  cidr_block        = "192.168.128.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "sillykloud-private1"
  }
}

resource "aws_subnet" "sillykloud-private2" {
  vpc_id            = aws_vpc.sillykloud.id
  cidr_block        = "192.168.192.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "sillykloud-private2"
  }
}
