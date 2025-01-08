
### Backend definition

# terraform {
#   # The configuration for this backend will be filled in by Terragrunt
#   backend "s3" {}
# }


provider "aws" {
  region = var.aws_region
}

locals {
  azs_with_index = { for az in var.azs : az => index(var.azs, az) }
}

########################################################################################################################
### Step 1 - VPC
########################################################################################################################

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(
    var.tags,
    {
      "Name"        = format("%s-vpc", var.name)
      "TerraformId" = format("%s-vpc", var.name)
    },
  )
}

########################################################################################################################
### Step 2 & 3 - AZS and Subnets
########################################################################################################################

# Create private subnets (1 per AZ)
resource "aws_subnet" "private" {
  for_each          = local.azs_with_index
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.cidr, 4, each.value)
  availability_zone = "${var.aws_region}${each.key}"

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-private-%s%s", var.name, var.aws_region, each.key)
    },
    {
      "TerraformId" = format("%s-private-%s%s", var.name, var.aws_region, each.key)
    },
    {
      "Tier" = "private"
    },
  )
}

# Create public subnets (1 per AZ)
resource "aws_subnet" "public" {
  for_each                = local.azs_with_index
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.cidr, 4, 15 - each.value)
  availability_zone       = "${var.aws_region}${each.key}"
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      "Name" = format("%s-public-%s%s", var.name, var.aws_region, each.key)
    },
    {
      "TerraformId" = format("%s-public-%s%s", var.name, var.aws_region, each.key)
    },
    {
      "Tier" = "public"
    },
  )
}

########################################################################################################################
### Step 4 - Gateways
########################################################################################################################

# Create Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-igw", var.name)
    },
    {
      "TerraformId" = format("%s-igw", var.name)
    },
  )
}

resource "aws_nat_gateway" "nat" {
  for_each      = local.azs_with_index
  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    "Name" = format("%s-nat-%s%s", var.name, var.aws_region, each.key)
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.igw,
    aws_route.public_igw_world
  ]
}


resource "aws_eip" "nat" {
  for_each = local.azs_with_index
  vpc      = true
}

########################################################################################################################
### Step 5 - Route tables
########################################################################################################################

# Create public route table (1 for all AZs)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-public", var.name)
    },
    {
      "TerraformId" = format("%s-public", var.name)
    },
  )
}

# Create routes for public route table
# 0.0.0.0/0 pointing to the igw (enable communication with Internet)
resource "aws_route" "public_igw_world" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Create private route table (1 per AZ)
resource "aws_route_table" "private" {
  for_each = local.azs_with_index
  vpc_id   = aws_vpc.vpc.id
  tags = merge(
    var.tags,
    {
      "Name" = format("%s-private-%s", var.name, each.key)
    },
    {
      "TerraformId" = format("%s-private-%s", var.name, each.key)
    },
  )
}

# 0.0.0.0/0 should go through Instance Nat in order to enable Internet access
resource "aws_route" "private_instance_ngw_world" {
  for_each               = local.azs_with_index
  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[each.key].id
}

# Associate route table with subnets

resource "aws_route_table_association" "public" {
  for_each       = local.azs_with_index
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each       = local.azs_with_index
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}
