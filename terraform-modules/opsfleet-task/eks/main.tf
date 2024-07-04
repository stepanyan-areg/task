module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.9.0"

  cluster_name    = var.environment
  cluster_version = var.kube_version

  cluster_endpoint_public_access        = true
  enable_cluster_creator_admin_permissions = true  

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
        # Ensure that we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
        tolerations = [
          {
            key      = "eks.amazonaws.com/compute-type"
            operator = "Equal"
            value    = "fargate"
            effect   = "NoSchedule"
          }
        ]
      })
    }
    kube-proxy = {}
    vpc-cni    = {}
  }

  # authentication_mode = "API_AND_CONFIG_MAP"
  # access_entries = {
  #   developer_access = {
  #     kubernetes_groups = ["admin"]
  #     principal_arn     = "arn:aws:iam::115525075501:user/dev"
  #   }
  # }


  tags = merge(var.tags, {
    "karpenter.sh/discovery" = var.environment
  })

  vpc_id     = var.vpc
  subnet_ids = var.subnets

  create_cluster_security_group = false
  create_node_security_group    = false  


  fargate_profiles = {
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }
  
}

