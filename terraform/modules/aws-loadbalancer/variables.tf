variable "config" {
  description = "The config to create the Load Balancer with."
  type = object({
    cluster-name       = string
    load-balancer-type = optional(string, "application")
    subnets            = list(string)
    vpc                = string
  })
}
