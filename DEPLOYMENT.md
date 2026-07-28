# Deployment

Terraform IaC for this submission lives under `terraform/`, starting
with [`terraform/bootstrap/`](terraform/bootstrap/README.md) which
provisions the S3 bucket used for the main stack's remote state. The
main stack itself (deploying the app, load balancer, and TLS) is a
separate, later piece of work.
