resource "aws_subnet" "public_subnet" {
  for_each = {
    for index, az in var.az : az => {
      cidr = var.cidr_block_public[index]
    }
  }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.key
  map_public_ip_on_launch = true
  tags = {
    Name      = "public-subnet-${each.key}"
    Terraform = "true"
  }
}

resource "aws_subnet" "private_subnet" {
  for_each = {
    for index, az in var.az : az => {
      cidr = var.cidr_block_private[index]
    }
  }
  vpc_id                  = var.vpc_id
  cidr_block              = each.value.cidr
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags = {
    Name      = "private-subnet-${each.key}"
    Terraform = "true"
  }
}
