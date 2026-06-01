variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "igw_id" {
  type = string
}

variable "nat_gateway_id" {
  type = string
}
