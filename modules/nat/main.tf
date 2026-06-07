resource "aws_eip" "my_eip" {
  domain = "vpc"
  tags = {
    Name      = "my-eip"
    Terraform = "true"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  subnet_id     = values(var.public_subnet_ids)[0]
  allocation_id = aws_eip.my_eip.id
  tags = {
    Name      = "my-nat-gateway"
    Terraform = "true"
  }
}
