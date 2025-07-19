module "eks_network" {
  source       = "./modules/network"
  cidr_block   = var.cidr_block
  project_name = var.project_name
  tags         = local.tags
}

module "eks_cluster" {
  source           = "./modules/cluster"
  project_name     = var.project_name
  public_subnet_1a = module.eks_network.subnet_pub_1a
  public_subnet_1b = module.eks_network.subnet_pub_1b
  tags             = local.tags
}

module "eks_managed_node_group" {
  source            = "./modules/managed-node-group"
  project_name      = var.project_name
  tags              = local.tags
  cluster_name      = module.eks_cluster.cluster_name
  private_subnet_1a = module.eks_network.subnet_priv_1a
  private_subnet_1b = module.eks_network.subnet_priv_1b
}

module "eks-aws-load-balancer-controller" {
  source       = "./modules/aws-load-balancer-controller"
  project_name = var.project_name
  tags         = local.tags
  oidc         = module.eks_cluster.oidc
  cluster_name = module.eks_cluster.cluster_name
}