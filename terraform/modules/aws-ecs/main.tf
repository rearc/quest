resource "aws_ecs_cluster" "this" {
  name = var.config.cluster-name

  configuration {
    execute_command_configuration {
      kms_key_id = local.kms-key-arn
      logging    = var.config.logging-command-configuration

      log_configuration {
        cloud_watch_encryption_enabled = var.config.cloud-watch-encryption-enabled
        cloud_watch_log_group_name     = local.cloudwatch-log-group-name
      }
    }
  }

  tags = {
    "Name" = var.config.cluster-name
  }
}

# TODO: Create an ECS Service
# TODO: Create a VPC
# TODO: Create a task definition
# TODO: Create an ALB
