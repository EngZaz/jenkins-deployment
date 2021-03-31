output "master-node-ip" {
  value = aws_instance.jenkins-master.public_ip
}
output "workers-node-ips" {
  value = {
    for instance in aws_instance.jenkins-workers :
    instance.id => instance.public_ip
  }
}
output "masterAmi" {
  value = data.aws_ssm_parameter.LinuxAmiEast.value
}
output "WorkersAmi" {
  value = data.aws_ssm_parameter.LinuxAmiWest.value
}
