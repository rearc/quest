output "load-balancer-dns" {
  description = "The Load Balancer DNS name to reach the deployed web app."
  value       = module.load-balancer.load-balancer-dns
}
