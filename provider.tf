terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket  = "terraform-backend-alextonkovid"
    key     = "terraform-provision.tfstate"
    region  = "eu-west-3"
    encrypt = true
  }
}
