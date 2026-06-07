terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
  }
}

data "tls_certificate" "eks" {
  url = var.my-cluster_identity
}

resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    data.tls_certificate.eks.certificates[0].sha1_fingerprint
  ]

  url = var.my-cluster_identity
}

resource "aws_iam_policy" "cluster_autoscaler" {

  name = "cluster-autoscaler-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions"
        ]

        Resource = "*"
      },

      {
        Effect = "Allow"

        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]

        Resource = "*"
      }
    ]
  })
}

data "aws_iam_policy_document" "cluster_autoscaler_assume_role" {

  statement {

    actions = ["sts:AssumeRoleWithWebIdentity"]

    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {

      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:kube-system:cluster-autoscaler"
      ]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {

  name = "cluster-autoscaler-role"

  assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {

  role = aws_iam_role.cluster_autoscaler.name

  policy_arn = aws_iam_policy.cluster_autoscaler.arn
}

resource "helm_release" "cluster_autoscaler" {

  name = "cluster-autoscaler"

  repository = "https://kubernetes.github.io/autoscaler"

  chart = "cluster-autoscaler"

  namespace = "kube-system"

  set = [{
    name  = "autoDiscovery.clusterName"
    value = var.my-cluster-name
    },
    {
      name  = "awsRegion"
      value = "eu-north-1"
    },
    {
      name  = "rbac.serviceAccount.create"
      value = "true"
    },
    {
      name  = "rbac.serviceAccount.name"
      value = "cluster-autoscaler"
    },
    {
      name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
      value = aws_iam_role.cluster_autoscaler.arn
    }
  ]

}

resource "helm_release" "metric_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
}

resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  namespace        = "ingress-nginx"
  create_namespace = true

  wait = true
}
