resource "aws_vpc" "pro-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "terraform-vpc"
  }
}

resource "aws_internet_gateway" "pro-ig" {
  vpc_id = aws_vpc.pro-vpc.id
  tags = {
    Name = "terraform-ig"
  }
}

resource "aws_subnet" "my-public-subnet" {
  vpc_id     = aws_vpc.pro-vpc.id
  cidr_block = "10.0.0.0/24"
  tags = {
    Name = "terraform-public-subnet"
  }
}

resource "aws_subnet" "my-private-subnet" {
  vpc_id     = aws_vpc.pro-vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "terraform-private-subnet"
  }
}

resource "aws_route_table" "my-public-rt" {
  vpc_id = aws_vpc.pro-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pro-ig.id
  }

  tags = {
    Name = "terraform-public-rt"
  }
}

resource "aws_route_table" "my-private-rt" {
  vpc_id = aws_vpc.pro-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.my-nat-gw.id
  }

  tags = {
    Name = "terraform-private-rt"
  }
}

resource "aws_route_table_association" "public-association" {
  subnet_id      = aws_subnet.my-public-subnet.id
  route_table_id = aws_route_table.my-public-rt.id
}

resource "aws_route_table_association" "private-association" {
  subnet_id      = aws_subnet.my-private-subnet.id
  route_table_id = aws_route_table.my-private-rt.id
}

resource "aws_eip" "pro-eip" {
  vpc = true
  tags = {
    Name = "pro-eip"
  }
}

resource "aws_nat_gateway" "my-nat-gw" {
  allocation_id = aws_eip.pro-eip.id
  subnet_id     = aws_subnet.my-private-subnet.id
  tags = {
    Name = "terraform-nat-gw"
  }
}