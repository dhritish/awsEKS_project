output "my-cluster" {
  value = aws_eks_cluster.my-cluster.cluster_id
}

output "my-nodes" {
  value = aws_eks_node_group.nodes.id
}

output "my-cluster-name" {
  value = aws_eks_cluster.my-cluster.name
}

output "url" {
  value = aws_eks_cluster.my-cluster.identity[0].oidc[0].issuer
}

output "certificate" {
  value = aws_eks_cluster.my-cluster.certificate_authority[0].data
}

output "endpoint" {
  value = aws_eks_cluster.my-cluster.endpoint
}
