output "my_nat_gateway_id" {
  value = aws_nat_gateway.my_nat_gateway.id
}

output "my_eip" {
  value = aws_eip.my_eip.public_ip
}
