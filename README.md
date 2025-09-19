# Terraform AWS VPC

## :package: Install Terraform

Install Terraform by following the [documentation](https://www.terraform.io/downloads)

Make sure `terraform` is working properly

```hcl
$ terraform
Usage: terraform [--version] [--help] <command> [args]

The available commands for execution are listed below.
The most common, useful commands are shown first, followed by
less common or more advanced commands. If you're just getting
started with Terraform, stick with the common commands. For the
other commands, please read the help and docs before usage.

Common commands:
    apply              Builds or changes infrastructure
    console            Interactive console for Terraform interpolations
# ...
```

*Based on [standard module structure](https://www.terraform.io/docs/modules/create#standard-module-structure) guidelines*

## :triangular_ruler: Naming Convention

Common variables referenced in naming standards

| Variable              | RegExp                          | Example                                                     |
|:----------------------|:--------------------------------|:------------------------------------------------------------|
| `<availability_zone>` | `[a-z]{2}-[a-z]{1,}-[1-2][a-f]` | `us-east-1a`, `us-west-2c`, `eu-west-1a`, `ap-northeast-1c` |

---

## AWS - Resource Naming Standards

| AWS Resource     | Resource Naming                          | Comment | Example                          |
|:-----------------|:-----------------------------------------|:--------|:---------------------------------|
| VPC              | `<vpc_name>-vpc`                         |         | `mycloud-vpc`                    |
| Subnets          | `<vpc_name>-private-<availability_zone>` |         | `mycloud-private-us-east-1b` |
|                  | `<vpc_name>-public-<availability_zone>`                      |         | `mycloud-public-us-east-1b`             |
| Route Tables     | `<vpc_name>-private-<availability_zone>` |         | `mycloud-private-us-east-1b` |
|                  | `<vpc_name>-public`                      |         | `mycloud-public`             |
| Internet Gateway | `<vpc_name>-igw`                         |         | `mycloud-igw`                |
| Nat Gateway      | `<vpc_name>-nat-<availability_zone>`     |         | `mycloud-nat-us-east-1b`     |


## 1. Create a `VPC`

The really first stage for bootstrapping an AWS account is to create a `VPC`

* [aws_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc)

![VPC AZs](./docs/2-vpc-azs.png)

## 2. Create `public` and `private` Subnets

Then create `public` and `private` subnets in each `AZs` (`us-east-1a`, `us-east-1b`, `us-east-1c`)

* [aws_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet)

![VPC AZs Subnets](./docs/3-vpc-azs-subnets.png)

## 3. Create `internet` and `nat` Gateways

Create one `internet gateway` so that the `VPC` can communicate with the outisde world. For instances located in `private` subnets, we will need `NAT` gateways to be setup in each `availability zones`

* [aws_internet_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway)
* [aws_nat_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway)
* [aws_eip](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip)

![VPC AZs Subnets GW](./docs/4-vpc-azs-subnets-gw.png)

## 4. Create `route tables` and `routes`

Finaly, link the infrastructure together by creating `route tables` and `routes` so that servers from `public` and `private` subnets can send their traffic to the respective gateway, either the `internet gateway` or the `NAT` ones.

* [aws_route_table](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table)
* [aws_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route)
* [aws_route_table_association](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association)

![VPC AZs Subnets GW Routes](./docs/5-vpc-azs-subnets-gw-routing.png)

## Tips and Tricks

* Connect to AWS private instance using a NAT server as a jumphost

```sh
eval $(ssh-agent)
ssh-add <keypair.pem>
ssh -i key-pair/aws-educate-student.pem -J ec2-user@<public-NAT-IP> -A ec2-user@<private-EC2-IP>
```
