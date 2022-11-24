module "dns-records" {
  source = "./modules/cloudflare-dns-record"

  config = {
    root-domain-name = local.domain-name
    dns-record = {
      name    = local.sub-domain-name
      proxied = true
      value   = module.load-balancer.load-balancer-dns
    }
  }
}
