# Create VPC in east region
resource "aws_vpc" "vpc_east" {
  provider             = aws.east
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-east"
  }
}

# Create a VPC in west region
resource "aws_vpc" "vpc_west" {
  provider             = aws.west
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc-west"
  }
}

# Create IGW in east
resource "aws_internet_gateway" "igw-east" {
  vpc_id   = aws_vpc.vpc_east.id
  provider = aws.east
  tags = {
    Name = "igw-east"
  }
}

# Create IGW in west
resource "aws_internet_gateway" "igw-west" {
  vpc_id   = aws_vpc.vpc_west.id
  provider = aws.west
  tags = {
    Name = "igw-west"
  }
}

# to get the Availability zones in the region then we will use them for assigning subntes for different zones

data "aws_availability_zones" "avz_east" {
  provider = aws.east
  state    = "available"
}

data "aws_availability_zones" "avz_west" {
  provider = aws.west
  state    = "available"
}

# Create subnets

resource "aws_subnet" "east_subnet1" {
  vpc_id            = aws_vpc.vpc_east.id
  cidr_block        = "10.0.1.0/24"
  provider          = aws.east
  availability_zone = element(data.aws_availability_zones.avz_east.names, 0)
  tags = {
    Name = "east_subnet1"
  }
}

resource "aws_subnet" "east_subnet2" {
  vpc_id            = aws_vpc.vpc_east.id
  cidr_block        = "10.0.2.0/24"
  provider          = aws.east
  availability_zone = element(data.aws_availability_zones.avz_east.names, 1)
  tags = {
    Name = "east_subnet2"
  }
}


resource "aws_subnet" "west_subnet1" {
  vpc_id            = aws_vpc.vpc_west.id
  cidr_block        = "192.168.0.0/24"
  provider          = aws.west
  availability_zone = element(data.aws_availability_zones.avz_west.names, 0)
  tags = {
    Name = "west_subnet1"
  }
}

resource "aws_subnet" "west_subnet2" {
  vpc_id            = aws_vpc.vpc_west.id
  cidr_block        = "192.168.1.0/24"
  provider          = aws.west
  availability_zone = element(data.aws_availability_zones.avz_west.names, 1)
  tags = {
    Name = "west_subnet2"
  }
}


# The east region VPC request vpc peering
resource "aws_vpc_peering_connection" "east_west_peering" {
  provider    = aws.east
  peer_vpc_id = aws_vpc.vpc_west.id
  vpc_id      = aws_vpc.vpc_east.id
  peer_region = var.region-west
}

# The west region vpc will accept the connection
resource "aws_vpc_peering_connection_accepter" "west_side_peering" {
  provider                  = aws.west
  vpc_peering_connection_id = aws_vpc_peering_connection.east_west_peering.id
  auto_accept               = true
}

# Create Route tbale for east us

resource "aws_route_table" "east_rt" {
  vpc_id   = aws_vpc.vpc_east.id
  provider = aws.east
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-east.id
  }

  route {
    cidr_block                = "192.168.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.east_west_peering.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "East-Region-RT"
  }
}
# associate the east route table to the east vpc
resource "aws_main_route_table_association" "east_rt_association" {
  vpc_id         = aws_vpc.vpc_east.id
  provider       = aws.east
  route_table_id = aws_route_table.east_rt.id
}
# Create Route tbale for west us

resource "aws_route_table" "west_rt" {
  vpc_id   = aws_vpc.vpc_west.id
  provider = aws.west

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-west.id
  }

  route {
    cidr_block                = "10.0.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.east_west_peering.id
  }

  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "West-Region-RT"
  }
}

# associate the west route table to the west vpc
resource "aws_main_route_table_association" "west_rt_association" {
  vpc_id         = aws_vpc.vpc_west.id
  provider       = aws.west
  route_table_id = aws_route_table.west_rt.id
}
