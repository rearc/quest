# Terraform bootstrap

Creates the S3 bucket used as the remote state backend for the main
infrastructure stack (a separate, later Terraform root module). This
module is applied **once, manually, before the main stack exists** —
it cannot use the backend it's creating.

## Requirements

Terraform >= 1.11.0 (pinned in `versions.tf`, required for `use_lockfile`
native S3 locking) and AWS provider ~> 5.0 (currently resolves to
5.100.0, see `.terraform.lock.hcl`).

## Why this is separate from the main stack

Terraform can't configure a remote backend that doesn't exist yet. This
module uses the default **local** backend (a `terraform.tfstate` file in
this directory, already covered by the repo's `.gitignore`) and is not
meant to be re-applied often — just once per environment/account.

**Known limitation:** because this module's own state is local, losing
that local state file means Terraform loses track of the bucket it
created. The bucket name is deterministic
(`<project_name>-tfstate-<AWS account ID>`, not a random value), so the
bucket can still be located and reattached — e.g.
`terraform import aws_s3_bucket.terraform_state <bucket-name>` (plus the
other resources) — rather than being orphaned. Acceptable for a
single-environment take-home; a team setting would put this bootstrap
state in a pre-existing shared bucket or a Terraform Cloud workspace
instead.

## Design notes

- **SSE-S3 (AES256) over SSE-KMS:** a deliberate simplicity/cost
  tradeoff for a take-home — no KMS key to create, rotate, or pay for.
  A production setup would likely use a customer-managed KMS key for
  audit-logged access control.
- **No `prevent_destroy`:** the quest's own workflow expects the whole
  deployment, including this bucket, to be torn down after a completion
  screenshot — a hard destroy-block would just be a self-inflicted
  surprise later. See **Tearing down** below.
- **90-day noncurrent-version expiration:** versioning is required for
  state recovery, but old versions would otherwise accumulate forever —
  the lifecycle rule expires noncurrent versions after 90 days to bound
  storage growth.
- **Non-negotiable baseline controls:** a bucket policy denies all S3
  access over non-TLS connections (`aws:SecureTransport` = false), and a
  public-access block enables all four block/ignore/restrict settings —
  these aren't optional hardening, they're the minimum for a state
  bucket.

## Tearing down

Because versioning is enabled, S3 won't let `terraform destroy` remove
the bucket while it still holds object versions or delete markers —
purge both first:

```bash
aws s3api delete-objects --profile rearc-quest --bucket <bucket-name> --delete "$(
  aws s3api list-object-versions --profile rearc-quest --bucket <bucket-name> \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"

aws s3api delete-objects --profile rearc-quest --bucket <bucket-name> --delete "$(
  aws s3api list-object-versions --profile rearc-quest --bucket <bucket-name> \
    --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}')"
```

(Each call handles up to 1000 keys; on a bucket with more history, repeat
until `list-object-versions` returns no more entries.)

Then:

```bash
cd terraform/bootstrap
terraform destroy
```

## Inputs

| Name | Default | Description |
|---|---|---|
| `aws_region` | `us-east-1` | AWS region for the Terraform state bucket. |
| `project_name` | `rearc-quest` | Prefix used when naming the state bucket. |
| `aws_profile` | `rearc-quest` | AWS CLI/SSO profile used for authentication — override with `-var="aws_profile=..."` for a different profile. |

## Outputs

| Name | Description |
|---|---|
| `state_bucket_name` | Name of the S3 bucket that holds Terraform state for the main stack. |
| `state_bucket_region` | Region the Terraform state bucket lives in (from `var.aws_region`). |

## Usage

Authenticates via IAM Identity Center (SSO) under the `rearc-quest`
profile. One-time setup: `aws configure sso --profile rearc-quest`.

```bash
cd terraform/bootstrap
aws sso login --profile rearc-quest  # refresh SSO credentials
terraform init
terraform fmt -check
terraform validate
terraform test    # runs tests/state_bucket.tftest.hcl against a mocked
                   # AWS provider — no credentials or cost required
terraform plan     # requires the rearc-quest SSO profile above
terraform apply    # creates the real S3 bucket
```

## Wiring up the main stack

Once applied, note the `state_bucket_name` and `state_bucket_region`
outputs and use them in the main stack's backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket       = "<state_bucket_name output>"
    key          = "rearc-quest/terraform.tfstate"
    region       = "<state_bucket_region output>"
    encrypt      = true
    use_lockfile = true # native S3 locking, no DynamoDB table needed
  }
}
```
