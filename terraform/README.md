## To Apply:

Due to a race condition with cloudflare and acm validation, currently you need
to run the following command first followed by a `terraform apply`.

```bash
tf apply -target='module.certificate.aws_acm_certificate.this'
```
