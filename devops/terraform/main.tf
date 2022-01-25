locals {
  name       = "laravel-app"
  region     = "us-east-1"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDPVQdKu/fLPd64VEsVyvZU29u8PnZZH0SRD5+vQJDUpLcbwjvKIrKjS/knkavQFIQo7mtbKdWT3Yr4s5FFN4w7eWAb7AZjKd0hbBXj1yIcQH0+Z9JdRSegTHffInl2+5rev862AnWq0wdg0DAjZMgND5OkZ/G4nV99lBTk3nkOtxVFK1dmpy/7JrGZNIqahZRy6Q1lp3KA5l2j1D9UTFUXb7DOz82h/He08+mpsdOHP4xdlV3EPzMHna1rsrHkY0T6HPKU4oPVn/sbpNWMZadS6ozdNa8TDXY9OOZ9mhRZrE/ahV2x/PAOIvMoKVjl2jMqZ1mgTo9eqPv7J1BUg1lkTmhJZY6LiuPapzA0aKY7oLmXZyQJ5wLJzrQNcmuUEmixrrLR0Hj2E6qDup4csuWzC1gTEicYV1qqE3d+TLYdsMDJLjfNc6t4X8L4TOi9cZvAp1zHxfxEiiCbk9ppjw+zYYvN45e8lx0imPQ/3PsBQqDtEhNMIuEaTcZIq8BHUyc= sargsyan.vzgg@gmail.com"

  tags = {
    Owner       = "user"
    Environment = "dev"
  }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.99.0.0/18"

  azs              = ["${local.region}a", "${local.region}b", "${local.region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]

  tags = local.tags
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp", "http-80-tcp", "https-443-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

resource "aws_network_interface" "this" {
  subnet_id = element(module.vpc.public_subnets, 0)
}

################################################################################
# EC2 Module
################################################################################
resource "aws_key_pair" "ssh_key" {
  public_key = local.public_key
}

module "ec2_complete" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.4"

  name = local.name

  ami                         = "ami-04505e74c0741db8d"
  instance_type               = "t2.micro"
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true

  key_name = aws_key_pair.ssh_key.key_name

  enable_volume_tags = false
  root_block_device  = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 20
      tags        = {
        Name = "my-root-block"
      }
    },
  ]

  tags = local.tags
}
