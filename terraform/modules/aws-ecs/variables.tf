variable "config" {
  description = "The config to create the ECS cluster with."
  type = object({
    cluster-name                   = string
    kms-key-arn                    = optional(string, null)
    logging-command-configuration  = optional(string, "OVERRIDE")
    cloud-watch-encryption-enabled = optional(bool, true)
    cloud-watch-log-group-name     = optional(bool, null)
    task-definition-file           = optional(string, null)
    launch-type                    = optional(list, "FARGATE")
    task-definition-network-mode   = optional(string, "awsvpc")
    task-definition-memory         = optional(number, 512)
    task-definition-cpu            = optional(number, 256)
    task-definition-container-port = optional(number, 3000)
    task-definition-host-port      = optional(number, 3000)
    ecs-service-count              = optional(number, 1)
  })
}
