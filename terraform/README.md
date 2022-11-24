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

| Name                                                                        | Version |
| --------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | ~> 1.3  |
| <a name="requirement_aws"></a> [aws](#requirement_aws)                      | ~> 4.40 |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement_cloudflare) | ~> 3.0  |

## Providers

No providers.

## Modules

| Name                                                                                      | Source                          | Version |
| ----------------------------------------------------------------------------------------- | ------------------------------- | ------- |
| <a name="module_certificate"></a> [certificate](#module_certificate)                      | ./modules/aws-acm               | n/a     |
| <a name="module_container-registry"></a> [container-registry](#module_container-registry) | ./modules/aws-ecr               | n/a     |
| <a name="module_container-service"></a> [container-service](#module_container-service)    | ./modules/aws-ecs               | n/a     |
| <a name="module_dns-records"></a> [dns-records](#module_dns-records)                      | ./modules/cloudflare-dns-record | n/a     |
| <a name="module_load-balancer"></a> [load-balancer](#module_load-balancer)                | ./modules/aws-loadbalancer      | n/a     |
| <a name="module_network"></a> [network](#module_network)                                  | ./modules/aws-network           | n/a     |

## Resources

No resources.

## Inputs

| Name                                                                                 | Description                                              | Type                                                                                      | Default                        | Required |
| ------------------------------------------------------------------------------------ | -------------------------------------------------------- | ----------------------------------------------------------------------------------------- | ------------------------------ | :------: |
| <a name="input_aws-profile"></a> [aws-profile](#input_aws-profile)                   | The local AWS profile with access to the service account | `string`                                                                                  | `"benniemosher-quest-sandbox"` |    no    |
| <a name="input_cloudflare-config"></a> [cloudflare-config](#input_cloudflare-config) | The config to connect Terraform to Cloudflare            | <pre>object({<br> account-id = optional(string, null)<br> api-token = string<br> })</pre> | n/a                            |   yes    |
| <a name="input_region"></a> [region](#input_region)                                  | The AWS region in which to stand up resources            | `string`                                                                                  | `"us-east-1"`                  |    no    |

## Outputs

| Name                                                                                   | Description                                               |
| -------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| <a name="output_load-balancer-dns"></a> [load-balancer-dns](#output_load-balancer-dns) | The Load Balancer DNS name to reach the deployed web app. |
| <a name="output_url"></a> [url](#output_url)                                           | The URL for the web app.                                  |

<!-- END_TF_DOCS -->
