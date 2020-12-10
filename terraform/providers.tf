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
