## To get Cloudflare secrets:

Reach out to [@benniemosher](https://keybase.io/benniemosher) on Keybase and get access to his secrets repo then:

```bash
git clone keybase://private/benniemosher/secrets
ln -s $HOME/Code/personal/secrets/cloudflare.auto.tfvars ./cloudflare.auto.tfvars
```

## To Apply:

Due to a race condition with cloudflare and acm validation, currently you need
to run the following command first followed by a `terraform apply`.

```bash
tf apply -target='module.certificate.aws_acm_certificate.this'
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 4.40 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement\_cloudflare) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.41.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_certificate"></a> [certificate](#module\_certificate) | ./modules/aws-acm | n/a |
| <a name="module_container-registry"></a> [container-registry](#module\_container-registry) | ./modules/aws-ecr | n/a |
| <a name="module_container-service"></a> [container-service](#module\_container-service) | ./modules/aws-ecs | n/a |
| <a name="module_dns-records"></a> [dns-records](#module\_dns-records) | ./modules/cloudflare-dns-record | n/a |
| <a name="module_encryption-key"></a> [encryption-key](#module\_encryption-key) | ./modules/aws-kms | n/a |
| <a name="module_load-balancer"></a> [load-balancer](#module\_load-balancer) | ./modules/aws-loadbalancer | n/a |
| <a name="module_network"></a> [network](#module\_network) | ./modules/aws-network | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.cloudwatch-kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws-profile"></a> [aws-profile](#input\_aws-profile) | The local AWS profile with access to the service account | `string` | `"benniemosher-quest-sandbox"` | no |
| <a name="input_cloudflare-config"></a> [cloudflare-config](#input\_cloudflare-config) | The config to connect Terraform to Cloudflare | <pre>object({<br>    account-id = optional(string, null)<br>    api-token  = string<br>    cidrs      = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The AWS region in which to stand up resources | `string` | `"us-east-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load-balancer-dns"></a> [load-balancer-dns](#output\_load-balancer-dns) | The Load Balancer DNS name to reach the deployed web app. |
| <a name="output_url"></a> [url](#output\_url) | The URL for the web app. |
<!-- END_TF_DOCS -->
