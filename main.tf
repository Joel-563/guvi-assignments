terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.42.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
  alias  = "region1"
}

resource "aws_vpc" "region1_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  provider         = aws.region1
}

resource "aws_subnet" "region1_pub_subnet" {
  vpc_id     = aws_vpc.region1_vpc.id
  cidr_block = "10.0.1.0/24"
  provider   = aws.region1
}

resource "aws_subnet" "region1_priv_subnet" {
  vpc_id     = aws_vpc.region1_vpc.id
  cidr_block = "10.0.2.0/24"
  provider   = aws.region1
}

resource "aws_internet_gateway" "region1_igw" {
  vpc_id   = aws_vpc.region1_vpc.id
  provider = aws.region1
}

resource "aws_route_table" "region1_pub_rt" {
  vpc_id   = aws_vpc.region1_vpc.id
  provider = aws.region1

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.region1_igw.id
  }
}

resource "aws_route_table_association" "region1_pub_rt_assoc" {
  subnet_id      = aws_subnet.region1_pub_subnet.id
  route_table_id = aws_route_table.region1_pub_rt.id
}

resource "aws_eip" "region1_eip" {
  domain   = "vpc"
  provider = aws.region1
}

resource "aws_nat_gateway" "region1_nat_gw" {
  allocation_id = aws_eip.region1_eip.id
  subnet_id     = aws_subnet.region1_pub_subnet.id
  provider      = aws.region1
}

resource "aws_route_table" "region1_priv_rt" {
  vpc_id   = aws_vpc.region1_vpc.id
  provider = aws.region1

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.region1_nat_gw.id
  }
}

resource "aws_route_table_association" "region1_priv_rt_assoc" {
  subnet_id      = aws_subnet.region1_priv_subnet.id
  route_table_id = aws_route_table.region1_priv_rt.id
}

resource "aws_security_group" "region1_sg" {
  name        = "region1_sg"
  description = "Security group for region1"
  vpc_id      = aws_vpc.region1_vpc.id
  provider    = aws.region1

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from my IP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

}

resource "aws_instance" "region1_instance" {
  ami                         = "ami-0ed094fb1304fd857"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.region1_pub_subnet.id
  vpc_security_group_ids      = [aws_security_group.region1_sg.id]
  associate_public_ip_address = true
}


#####region 2

provider "aws" {
  region = "us-west-2"
  alias  = "region2"
}

resource "aws_vpc" "region2_vpc" {
  cidr_block       = "10.1.0.0/16"
  instance_tenancy = "default"
  provider         = aws.region2
}

resource "aws_subnet" "region2_pub_subnet" {
  vpc_id     = aws_vpc.region2_vpc.id
  cidr_block = "10.1.1.0/24"
  provider   = aws.region2
}

resource "aws_subnet" "region2_priv_subnet" {
  vpc_id     = aws_vpc.region2_vpc.id
  cidr_block = "10.1.2.0/24"
  provider   = aws.region2
}

resource "aws_internet_gateway" "region2_igw" {
  vpc_id   = aws_vpc.region2_vpc.id
  provider = aws.region2
}

resource "aws_route_table" "region2_pub_rt" {
  vpc_id   = aws_vpc.region2_vpc.id
  provider = aws.region2

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.region2_igw.id
  }
}

resource "aws_route_table_association" "region2_pub_rt_assoc" {
  subnet_id      = aws_subnet.region2_pub_subnet.id
  route_table_id = aws_route_table.region2_pub_rt.id
}

resource "aws_eip" "region2_eip" {
  domain   = "vpc"
  provider = aws.region2
}

resource "aws_nat_gateway" "region2_nat_gw" {
  allocation_id = aws_eip.region2_eip.id
  subnet_id     = aws_subnet.region2_pub_subnet.id
  provider      = aws.region2
}

resource "aws_route_table" "region2_priv_rt" {
  vpc_id   = aws_vpc.region2_vpc.id
  provider = aws.region2

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.region2_nat_gw.id
  }
}

resource "aws_route_table_association" "region2_priv_rt_assoc" {
  subnet_id      = aws_subnet.region2_priv_subnet.id
  route_table_id = aws_route_table.region2_priv_rt.id
}

resource "aws_security_group" "region2_sg" {
  name        = "region2_sg"
  description = "Security group for region2"
  vpc_id      = aws_vpc.region2_vpc.id
  provider    = aws.region2

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from my IP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
}

resource "aws_instance" "region2_instance" {
  ami                         = "ami-09667c8f5c7c258a2"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.region2_pub_subnet.id
  vpc_security_group_ids      = [aws_security_group.region2_sg.id]
  associate_public_ip_address = true
}
