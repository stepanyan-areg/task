resource "aws_security_group" "application" {
  name        = "${var.environment}-application"
  description = "Application Security Groups"
  vpc_id      = module.main.vpc_id

  tags = merge(
    { Name = "${var.environment}-application" },
    var.tags
  )
}

resource "aws_security_group_rule" "application_eg" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.application.id
}

resource "aws_security_group_rule" "application_self" {
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.application.id
  self              = true
}

resource "aws_security_group" "database" {
  vpc_id      = module.main.vpc_id
  name        = "${var.environment}-database"
  description = "Database Security Groups"
  tags = merge(
    { Name = "${var.environment}-database" },
    var.tags
  )
}

resource "aws_security_group_rule" "database_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.database.id
}

resource "aws_security_group_rule" "database_self" {
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.database.id
  self              = true
}

resource "aws_security_group_rule" "application_database" {
  type                     = "ingress"
  to_port                  = 5432
  protocol                 = "tcp"
  from_port                = 5432
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.application.id
}

resource "aws_security_group" "bastion" {
  name        = "${var.environment}-bastion"
  description = "Bastion Security Groups"
  vpc_id      = module.main.vpc_id

  tags = merge(
    { Name = "${var.environment}-bastion" },
    var.tags
  )
}

resource "aws_security_group_rule" "bastion_self" {
  type              = "ingress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  security_group_id = aws_security_group.bastion.id
  self              = true
}

resource "aws_security_group_rule" "bastion_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.bastion.id
}

resource "aws_security_group_rule" "bastion_database" {
  type                     = "ingress"
  to_port                  = 5432
  protocol                 = "tcp"
  from_port                = 5432
  security_group_id        = aws_security_group.database.id
  source_security_group_id = aws_security_group.bastion.id
}