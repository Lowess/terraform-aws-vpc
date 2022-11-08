resource "aws_security_group" "name" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-security-group"
    Environment = var.environment
    Owner = "nico.dvne@gmail.com"
  }
}

resource "aws_security_group_rule" "open-ssh-rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.name.id
}

resource "aws_security_group_rule" "internal-rule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.name.id
}