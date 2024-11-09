variable "default_zone" {
  default = "eu-west-3"
}

variable "key_pair_name" {
  default = "rsschool"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones to deploy resources"
  type        = list(string)
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "nat_ami" {
  description = "AMI ID for NAT instance, amzn-ami-vpc-nat-2018.03.0.20230807.0-x86_64-ebs"
  default     = "ami-083a66db966d63712"
}

variable "ubuntu_ami" {
  description = "AMI ID for Ubuntu instance ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20241002"
  default     = "ami-045a8ab02aadf4f88"
}

variable "ingress_cidr" {
  description = "Ingress CIDR block for inbound traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "egress_cidr" {
  description = "Egress CIDR block for outbound traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_ports" {
  description = "Ingress ports for TCP"
  type = object({
    from_port = number
    to_port   = number
  })
  default = {
    from_port = 0
    to_port   = 65535
  }
}

variable "ssh_private_key" {
  type        = string
  default = "~/.ssh/id_ed25519"
}