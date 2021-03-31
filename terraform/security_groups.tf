# Create the security group for the load balancer
resource "aws_security_group" "lb-sg" {
  name        = "lb-sg"
  description = "Allow Traffic for lb"
  vpc_id      = aws_vpc.vpc_east.id
  provider    = aws.east

  ingress {
    description = "allow https from everywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # http will be redirected to https by the lb
  ingress {
    description = "allow http from everywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create security group for east region where the jenkins master will be hosted

resource "aws_security_group" "jenkins-master-sg" {
  name        = "jenkins-master-sg"
  description = "Allow Traffic for master jenkins node"
  vpc_id      = aws_vpc.vpc_east.id
  provider    = aws.east

  ingress {
    description = "allow ssh from my ip address"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip]
  }

  # allow all to access port 8080 but only for traffic coming from the load balancer sg
  ingress {
    description = "allow 8080 from everywhere"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    # important note here to allow traffic coming from security group is done below, it is not well documented at terraform
    security_groups = [aws_security_group.lb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#Create SG for allowing TCP/22 from our IP in us-west-2
resource "aws_security_group" "jenkins-worker-sg" {
  provider = aws.west

  name        = "jenkins-worker-sg"
  description = "Allow TCP/8080 & TCP/22"
  vpc_id      = aws_vpc.vpc_west.id
  ingress {
    description = "Allow 22 from our public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myip]
  }
  ingress {
    description = "Allow traffic from us-east-1"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
