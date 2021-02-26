output "bastion_ip" {
  value = aws_instance.pub_bastion.public_ip
}