module "dns-records" {
  source = "./modules/cloudflare-dns-record"

  config = {
    root-domain-name = "benniemosher.dev"
  }
}
