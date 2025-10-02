module "eks_network" {
  source       = "./modules/network"
  cidr_block   = var.cidr_block
  project_name = var.project_name
  tags         = var.tags
}

module "eks_cluster" {
  source           = "./modules/cluster"
  project_name     = var.project_name
  public_subnet_1a = module.eks_network.subnet_pub_1a
  public_subnet_1b = module.eks_network.subnet_pub_1b
  tags             = var.tags
}

module "eks_managed_node_group" {
  source            = "./modules/managed-node-group"
  project_name      = var.project_name
  tags              = var.tags
  cluster_name      = module.eks_cluster.cluster_name
  private_subnet_1a = module.eks_network.subnet_priv_1a
  private_subnet_1b = module.eks_network.subnet_priv_1b
}

module "eks_add_ons" {
  source       = "./modules/add-ons"
  project_name = var.project_name
  tags         = var.tags
  oidc         = module.eks_cluster.oidc
  cluster_name = module.eks_cluster.cluster_name
  vpc_id       = module.eks_network.vpc_id
}

module "eks_ec2" {
  source            = "./modules/ec2"
  project_name      = var.project_name
  tags              = var.tags
  vpc_id            = module.eks_network.vpc_id
  public_subnet_1a  = module.eks_network.subnet_pub_1a
  private_subnet_1a = module.eks_network.subnet_priv_1a
  cluster_sg        = module.eks_cluster.cluster_sg
}