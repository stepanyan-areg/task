data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.main.vpc_id
}

resource "aws_security_group_rule" "allow_outbound" {
  security_group_id = data.aws_security_group.default.id
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]

  depends_on = [module.main]
}

resource "aws_security_group_rule" "allow_all_self" {
  security_group_id = data.aws_security_group.default.id
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  self              = true

  depends_on = [module.main]
}


module "main" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = var.environment

  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = var.single_nat_gateway

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []

  tags = merge({
    Name = var.environment
    },
  var.tags)

  private_subnet_tags = merge(
    { "kubernetes.io/role/elb-internal" = "1" },
    { "kubernetes.io/cluster/${var.environment}" = "shared" },
    { "karpenter.sh/discovery" = "${var.environment}" },
    { "kubernetes.io/role/internal-elb" = "1" }
  )

  public_subnet_tags = merge(
    { "kubernetes.io/cluster/${var.environment}" = "shared" },
    { "kubernetes.io/role/elb" = "1" }
  )
}

resource "aws_vpn_gateway" "vgw" {
  count  = var.create_vpn_gateway ? 1 : 0
  vpc_id = module.main.vpc_id
  tags = merge(
    { Name = var.environment },
  var.tags)
}
