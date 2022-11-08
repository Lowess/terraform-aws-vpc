// Création du VPC

resource "aws_vpc" "vpc" {
    cidr_block = var.cidr_block
    
    tags = local.vpc_tags
}

// Création des subnet publics et privés

resource "aws_subnet" "public" {

  for_each = var.availability_zones
  // each -> key = zone
  // each -> value = index

  vpc_id = aws_vpc.vpc.id
  availability_zone = "${var.aws_region}${each.key}"

  map_public_ip_on_launch = true

  #CIRD block of /20 will be generated
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, each.value)

  tags = {
    Name = "${var.vpc_name}-public-${var.aws_region}${each.key}"
    Environment = var.environment
    Owner = "Nicolas Davenne"
  }
}

resource "aws_subnet" "private" {

  for_each = var.availability_zones
  // each -> key = zone
  // each -> value = index

  vpc_id = aws_vpc.vpc.id
  availability_zone = "${var.aws_region}${each.key}"

  map_public_ip_on_launch = false

  #CIRD block of /20 will be generated
  cidr_block = cidrsubnet(aws_vpc.vpc.cidr_block, 4, 15 - each.value)

  tags = {
    Name = "${var.vpc_name}-private-${var.aws_region}${each.key}"
    Environment = var.environment
    Owner = "nico.dvne@gmail.com"
  }
}

// VPC Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name}-gateway"
    Environment = var.environment
    Owner = "nico.dvne@gmail.com"
  }
}