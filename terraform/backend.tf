terraform {
  backend "s3" {
    bucket = "engzaz"
    key    = "statefile1"
    region = "us-east-1"
  }
}

