#Get Linux ID using SSM parameter
data "aws_ssm_parameter" "LinuxAmiEast" {
  provider = aws.east
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}
data "aws_ssm_parameter" "LinuxAmiWest" {
  provider = aws.west
  name     = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

#Create key-pair for logging into EC2

resource "aws_key_pair" "east-key" {
  provider   = aws.east
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}
resource "aws_key_pair" "west-key" {
  provider   = aws.west
  key_name   = "jenkins"
  public_key = file("~/.ssh/id_rsa.pub")
}

#Create and bootstrap the master jenkins node
resource "aws_instance" "jenkins-master" {
  provider                    = aws.east
  ami                         = data.aws_ssm_parameter.LinuxAmiEast.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.east-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-master-sg.id]
  subnet_id                   = aws_subnet.east_subnet1.id

  tags = {
    "Name" = "Jenkins_master_tf"
  }

  depends_on = [aws_main_route_table_association.east_rt_association]
}

#Create and bootstrap the worker jenkins node
resource "aws_instance" "jenkins-workers" {
  provider                    = aws.west
  count                       = var.workers-count
  ami                         = data.aws_ssm_parameter.LinuxAmiWest.value
  instance_type               = var.instance-type
  key_name                    = aws_key_pair.west-key.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.jenkins-worker-sg.id]
  subnet_id                   = aws_subnet.west_subnet1.id

  tags = {
    "Name" = join("_", ["Jenkins_master_tf", count.index + 1])
  }

  depends_on = [aws_main_route_table_association.west_rt_association, aws_instance.jenkins-master]
}
