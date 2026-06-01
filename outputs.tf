output "my_vpc_id" {
  value = module.vpc.vpc_id
}

output "my_vpc_cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "my_vpc_tags" {
  value = module.vpc.vpc_tags
}

output "public_subnet_ids" {
  value = module.subnets.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.subnets.private_subnet_ids
}

output "my_igw_id" {
  value = module.igw.igw_id
}

output "my_nat_gateway_id" {
  value = module.nat.my_nat_gateway_id
}

output "my_eip" {
  value = module.nat.my_eip
}

output "my_public_route_table_id" {
  value = module.route.public_route_table
}

output "my_private_route_table_id" {
  value = module.route.private_route_table
}
