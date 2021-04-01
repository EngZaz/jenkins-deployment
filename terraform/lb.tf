#create ALB 
resource "aws_lb" "applb" {
  provider           = aws.east
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.east_subnet1.id, aws_subnet.east_subnet2.id]
  tags = {
    "name" = "jenkins-lb"
  }
}
