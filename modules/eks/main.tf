resource "aws_eks_cluster" "my-cluster" {
  name     = "my-cluster"
  role_arn = var.eks_cluster_role_arn

  vpc_config {
    subnet_ids = values(var.private_subnet_ids)
  }

  version = "1.35"

  tags = {
    Name      = "my-cluster"
    Terraform = "true"
  }
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.my-cluster.name
  node_group_name = "workers"

  node_role_arn = var.node_group_role_arn
  subnet_ids    = values(var.private_subnet_ids)

  instance_types = ["t3.micro"]
  ami_type       = "AL2023_x86_64_STANDARD"
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  node_repair_config {
    enabled = true
  }

  scaling_config {
    desired_size = 2
    max_size     = 5
    min_size     = 1
  }


  depends_on = [aws_eks_cluster.my-cluster]

  tags = {
    Name      = "my-nodes"
    Terraform = "true"

    "k8s.io/cluster-autoscaler/enabled"    = "true"
    "k8s.io/cluster-autoscaler/my-cluster" = "owned"
  }
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = aws_eks_cluster.my-cluster.name
  addon_name                  = "coredns"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name                = aws_eks_cluster.my-cluster.name
  addon_name                  = "vpc-cni"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name                = aws_eks_cluster.my-cluster.name
  addon_name                  = "kube-proxy"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}
