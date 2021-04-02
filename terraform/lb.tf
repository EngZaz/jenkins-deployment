#create ALB 
resource "aws_lb" "applb" {
  provider           = aws.east
  name               = "jenkins-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg.id]
  subnets            = [aws_subnet.east_subnet1.id, aws_subnet.east_subnet2.id]
  tags = {
    "name" = "jenkins-lb"
  }
}
resource "aws_lb_target_group" "app-lb-tg" {
  provider = aws.east
  name = "app-lb-tg"
  port = var.web-port
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc_east.id
  health_check {
    enaenabled          = true 
    interval            = 10    
    path                = "/"    
    port                = var.web-port
    matmatcher = "200-299"  
  }
  tags = {
    "Name" = "Jenkins-target-group"
  }
}

resource "aws_lb_target_group_attachment" "jenkins-master-attachment" {
  provider         = aws.east
  target_group_arn = aws_lb_target_group.app-lb-tg.arn
  target_id        = aws_instance.jenkins-master.id
  port             = var.web-port
}
