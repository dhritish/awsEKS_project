variable "vpc_id" {
  type = string
}

variable "az" {
  type = list(string)
}

variable "cidr_block_public" {
  type = list(string)
}

variable "cidr_block_private" {
  type = list(string)
}

