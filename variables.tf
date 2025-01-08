variable "aws_region" {
  type    = string
  default = "us-east-1"
}


variable "name" {
  type        = string
  description = "VPC Name"
}

variable "azs" {
  type        = list(string)
  description = "VPC AZs"
}

variable "cidr" {
  type        = string
  description = "VPC Cidr Block"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Default set of tags to apply to VPC resources"
}

### Boolean switch

variable "enable_bastion_host" {
  default     = true
  description = "If true, A bastion / jump host will be started in a public subnet"
}
