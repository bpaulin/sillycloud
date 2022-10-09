resource "aws_vpc" "sillykloud" {
  cidr_block = "192.168.0.0/16"
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "sillykloud-public1" {
  vpc_id            = aws_vpc.sillykloud.id
  cidr_block        = "192.168.0.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "sillykloud-public2" {
  vpc_id            = aws_vpc.sillykloud.id
  cidr_block        = "192.168.64.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "sillykloud-private1" {
  vpc_id            = aws_vpc.sillykloud.id
  cidr_block        = "192.168.128.0/18"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "sillykloud-private2" {
  vpc_id            = aws_vpc.sillykloud.id
  cidr_block        = "192.168.192.0/18"
  availability_zone = data.aws_availability_zones.available.names[1]
}
