variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable cidr_block {
  type = string
  description = "Le bloc CIDR du VPC. /16 est recommandé"
}

variable vpc_name {
  type = string
  description = "Nom du VPC"
}

variable environment {
  type = string
  description = "Label environnement du VPC"
}

variable tags {
  type = map(string)
  default = {
    Owner = "nico.dvne@gmail.com"
  }
}

variable availability_zones {
  type = map(string)
  default = {
    "f" = 0,
    "a" = 1,
    "c" = 2,
  }
  
}

