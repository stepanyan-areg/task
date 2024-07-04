
data "aws_ecrpublic_authorization_token" "token" {
  provider = aws.ohio
}

data "aws_eks_cluster" "default" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}
