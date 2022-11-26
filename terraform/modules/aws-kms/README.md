<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config"></a> [config](#input\_config) | Map of configuration for KMS key | <pre>object({<br>    deletion_window_in_days = optional(string, 10)<br>    description             = optional(string, "Managed by Terraform")<br>    enable_key_rotation     = optional(bool, true)<br>    name                    = string<br>    policy                  = optional(string, null)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the KMS key created. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the KMS key created. |
<!-- END_TF_DOCS -->