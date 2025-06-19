output "web_url" {
  value = "http://${module.ec2.web_server_public_ip}"
}
