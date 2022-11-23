module "dns-records" {
  source = "./modules/cloudflare-dns-record"

  config = {
    root-domain-name = "benniemosher.dev"
    dns-record = {
      name  = "quest"
      value = module.load-balancer.load-balancer-dns
    }
  }
}
