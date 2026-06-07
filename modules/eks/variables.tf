variable "private_subnet_ids" {
  type = map(string)
}

variable "eks_cluster_role_arn" {
  type = string
}

variable "node_group_role_arn" {
  type = string
}

