output "instance_name" {
  value = aws_instance.myinstance.tags["Name"]
}
output "instance_ip" {
  value = aws_instance.myinstance.public_ip

}