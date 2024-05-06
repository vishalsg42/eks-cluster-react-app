data "aws_availability_zones" "available" {}

# Create VPC
# resource "aws_vpc" "my_vpc" {
#   cidr_block = "10.0.0.0/16"
#   tags = {
#     Name = "eks-vpc"
#   }
# }

# # Create Internet Gateway
# resource "aws_internet_gateway" "my_igw" {
#   vpc_id = aws_vpc.my_vpc.id
# }

# # Create Public Subnets
# resource "aws_subnet" "public_subnet_1" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.1.0/24"
#   availability_zone =  data.aws_availability_zones.available.names[0]
# }

# resource "aws_subnet" "public_subnet_2" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.2.0/24"
#   availability_zone =  data.aws_availability_zones.available.names[1]
# }

# # Create Private Subnets
# resource "aws_subnet" "private_subnet_1" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.3.0/24"
#   availability_zone =  data.aws_availability_zones.available.names[0]
# }

# resource "aws_subnet" "private_subnet_2" {
#   vpc_id            = aws_vpc.my_vpc.id
#   cidr_block        = "10.0.4.0/24"
#   availability_zone =  data.aws_availability_zones.available.names[1]
# }

# # Create NAT Gateway
# resource "aws_nat_gateway" "my_nat_gateway" {
#   allocation_id = aws_eip.my_eip.id
#   subnet_id     = aws_subnet.private_subnet_1.id
# }

# # Associate EIP with NAT Gateway
# resource "aws_eip" "my_eip" {
# #   vpc = true
#     domain = "vpc"

# }

# # Create Route Tables
# resource "aws_route_table" "public_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.my_igw.id
#   }

#   tags = {
#     Name = "Public Route Table"
#   }
# }

# resource "aws_route_table" "private_route_table" {
#   vpc_id = aws_vpc.my_vpc.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
#   }

#   tags = {
#     Name = "Private Route Table"
#   }
# }

# # Associate Subnets with Route Tables
# resource "aws_route_table_association" "public_subnet_1_association" {
#   subnet_id      = aws_subnet.public_subnet_1.id
#   route_table_id = aws_route_table.public_route_table.id
# }

# resource "aws_route_table_association" "public_subnet_2_association" {
#   subnet_id      = aws_subnet.public_subnet_2.id
#   route_table_id = aws_route_table.public_route_table.id
# }

# resource "aws_route_table_association" "private_subnet_1_association" {
#   subnet_id      = aws_subnet.private_subnet_1.id
#   route_table_id = aws_route_table.private_route_table.id
# }

# resource "aws_route_table_association" "private_subnet_2_association" {
#   subnet_id      = aws_subnet.private_subnet_2.id
#   route_table_id = aws_route_table.private_route_table.id
# }

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  name               = "Infrastructure VPC"
  cidr               = "10.0.0.0/16"
  azs                = data.aws_availability_zones.available.names
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  enable_nat_gateway = true
}