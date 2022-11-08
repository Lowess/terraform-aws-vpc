data "aws_ami" "ami" {

    most_recent = true

    filter {
        name   = "name"
        values = ["amzn-ami-vpc-nat-2018.03.0.2021*"]
    }

    owners = ["amazon"]
}