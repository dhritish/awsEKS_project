provider "aws" {
  region = "eu-north-1"
}

module "vpc" {
  source     = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
  tags = {
    Name      = "my-vpc"
    Terraform = "true"
  }
}

module "subnets" {
  source             = "./modules/subnets"
  vpc_id             = module.vpc.vpc_id
  az                 = ["eu-north-1a", "eu-north-1b"]
  cidr_block_public  = ["10.0.1.0/24", "10.0.2.0/24"]
  cidr_block_private = ["10.0.3.0/24", "10.0.4.0/24"]
}

module "igw" {
  source = "./modules/igw"
  vpc_id = module.vpc.vpc_id
}

module "nat" {
  source            = "./modules/nat"
  public_subnet_ids = module.subnets.public_subnet_ids
}

module "route" {
  source             = "./modules/route"
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.subnets.private_subnet_ids
  public_subnet_ids  = module.subnets.public_subnet_ids
  igw_id             = module.igw.igw_id
  nat_gateway_id     = module.nat.my_nat_gateway_id
}

module "iam" {
  source = "./modules/iam"
}

module "eks" {
  source               = "./modules/eks"
  private_subnet_ids   = module.subnets.private_subnet_ids
  eks_cluster_role_arn = module.iam.eks_cluster_role_arn
  node_group_role_arn  = module.iam.node_group_role_arn
}

data "aws_eks_cluster_auth" "token" {
  name = module.eks.my-cluster-name
}

provider "kubernetes" {
  host                   = module.eks.endpoint
  cluster_ca_certificate = base64decode(module.eks.certificate)
  token                  = data.aws_eks_cluster_auth.token.token

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      module.eks.my-cluster-name
    ]
  }
}

provider "helm" {
  kubernetes = {
    host                   = module.eks.endpoint
    cluster_ca_certificate = base64decode(module.eks.certificate)
    token                  = data.aws_eks_cluster_auth.token.token

    exec = {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
        module.eks.my-cluster-name
      ]
    }
  }
}

module "cas" {
  source              = "./modules/cas"
  my-cluster_identity = module.eks.url
  my-cluster-name     = module.eks.my-cluster-name

  providers = {
    helm = helm
  }
}
