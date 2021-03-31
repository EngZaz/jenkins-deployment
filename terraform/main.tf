terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.34.0"
    }
  }

  required_version = "~> 0.14"
}

provider "aws" {
  profile = var.profile
  alias   = "east"
  region  = var.region-east
}

provider "aws" {
  profile = var.profile
  alias   = "west"
  region  = var.region-west
}
