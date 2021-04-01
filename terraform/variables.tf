variable "profile" {
  type    = string
  default = "default"
}
variable "region-east" {
  type    = string
  default = "us-east-1"
}

variable "region-west" {
  type    = string
  default = "us-west-2"
}

variable "myip" {
  type    = string
  default = "0.0.0.0/0"
}

variable "instance-type" {
  type    = string
  default = "t3.micro"
}
variable "workers-count" {
  type    = number
  default = 1
}
variable "web-port" {
  type = number
  description = "the port that will be open on the jenkins ec2"
  default = 80
}
