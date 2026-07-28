# Terraform State Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a standalone Terraform "bootstrap" module that provisions the S3 bucket the *main* infrastructure stack (built in a later plan) will use as its remote state backend, solving the chicken-and-egg problem of Terraform needing a backend that doesn't exist yet.

**Architecture:** A self-contained root module at `terraform/bootstrap/` with its own **local** state (never remote — it creates the remote backend, so it can't depend on one). It provisions one S3 bucket with versioning, noncurrent-version expiration, SSE-AES256 encryption, blocked public access, and a bucket policy denying non-TLS requests. The bucket name embeds the caller's AWS account ID (deterministic, not a random value) so it can be recognized and re-imported if the local bootstrap state is ever lost. Locking for the *main* stack's future S3 backend will use Terraform's native S3 conditional-write locking (`use_lockfile = true`, GA as of Terraform 1.11, which also deprecated the DynamoDB-based locking arguments) — no DynamoDB table. Correctness is verified with Terraform's native test framework (`terraform test`) using a fully mocked AWS provider, so tests run with no AWS credentials and no cost. The one real `terraform apply` against AWS is a manual, one-time step run by the user, not automated.

**Tech Stack:** Terraform >= 1.11.0, AWS provider `~> 5.0`, Terraform native test framework (`.tftest.hcl`).

**Prerequisites:**
- Terraform >= 1.11.0 installed locally (`terraform version`).
- AWS IAM Identity Center (SSO) configured locally under the `rearc-quest` profile (`aws configure sso --profile rearc-quest`), refreshed with `aws sso login --profile rearc-quest` before `plan`/`apply` — only needed for the final manual step, not for any task in this plan (the automated tests use a fully mocked provider and need no credentials).

---

### Task 1: Module scaffold and version pins

**Files:**
- Create: `terraform/bootstrap/versions.tf`
- Create: `terraform/bootstrap/providers.tf`
- Create: `terraform/bootstrap/variables.tf`

- [ ] **Step 1: Create `terraform/bootstrap/versions.tf`**

```hcl
terraform {
  required_version = ">= 1.11.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

- [ ] **Step 2: Create `terraform/bootstrap/providers.tf`**

```hcl
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
```

- [ ] **Step 3: Create `terraform/bootstrap/variables.tf`**

```hcl
variable "aws_region" {
  description = "AWS region for the Terraform state bucket."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Prefix used when naming the Terraform state bucket."
  type        = string
  default     = "rearc-quest"
}

variable "aws_profile" {
  description = "AWS CLI profile (configured via IAM Identity Center / SSO) used for authentication."
  type        = string
  default     = "rearc-quest"
}
```

- [ ] **Step 4: Initialize and validate the module**

Run: `cd terraform/bootstrap && terraform init`
Expected: `Terraform has been successfully initialized!` with `hashicorp/aws` listed as an installed provider.

Run: `terraform fmt -check`
Expected: no output, exit code `0` (files are already correctly formatted).

Run: `terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 5: Commit**

```bash
cd /Users/pkordes/work/git/rearc-quest
git add terraform/bootstrap/versions.tf terraform/bootstrap/providers.tf terraform/bootstrap/variables.tf
git commit -m "terraform: scaffold bootstrap module with version pins"
```

---

### Task 2: State bucket resource, TDD via `terraform test`

**Files:**
- Create: `terraform/bootstrap/tests/state_bucket.tftest.hcl`
- Create: `terraform/bootstrap/main.tf`
- Create: `terraform/bootstrap/outputs.tf`

- [ ] **Step 1: Write the failing test**

```hcl
# terraform/bootstrap/tests/state_bucket.tftest.hcl

mock_provider "aws" {}

run "state_bucket_has_versioning_enabled" {
  command = plan

  assert {
    condition     = aws_s3_bucket_versioning.terraform_state.versioning_configuration[0].status == "Enabled"
    error_message = "Terraform state bucket must have versioning enabled so state history can be recovered."
  }
}

run "state_bucket_expires_noncurrent_versions" {
  command = plan

  assert {
    condition     = aws_s3_bucket_lifecycle_configuration.terraform_state.rule[0].noncurrent_version_expiration[0].noncurrent_days == 90
    error_message = "Terraform state bucket must expire noncurrent versions so version history doesn't grow unbounded."
  }
}

run "state_bucket_blocks_public_access" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.block_public_acls == true
    error_message = "Terraform state bucket must block public ACLs."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.block_public_policy == true
    error_message = "Terraform state bucket must block public bucket policies."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.ignore_public_acls == true
    error_message = "Terraform state bucket must ignore public ACLs set on existing objects."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.terraform_state.restrict_public_buckets == true
    error_message = "Terraform state bucket must restrict public bucket access."
  }
}

run "state_bucket_uses_server_side_encryption" {
  command = plan

  assert {
    condition     = one(aws_s3_bucket_server_side_encryption_configuration.terraform_state.rule).apply_server_side_encryption_by_default[0].sse_algorithm == "AES256"
    error_message = "Terraform state bucket must use SSE-AES256 encryption by default."
  }
}

run "state_bucket_name_uses_project_prefix" {
  command = plan

  variables {
    project_name = "rearc-quest"
  }

  assert {
    condition     = startswith(aws_s3_bucket.terraform_state.bucket, "rearc-quest-tfstate-")
    error_message = "State bucket name must start with '<project_name>-tfstate-'."
  }
}
```

- [ ] **Step 2: Run the test suite to verify it fails**

Run: `terraform test`
Expected: FAIL — `Error: Reference to undeclared resource` for `aws_s3_bucket_versioning.terraform_state`, `aws_s3_bucket_lifecycle_configuration.terraform_state` (and the other resources), because none of them exist in the module yet.

- [ ] **Step 3: Implement the state bucket resources**

```hcl
# terraform/bootstrap/main.tf

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.project_name}-tfstate-${data.aws_caller_identity.current.account_id}"

  tags = {
    Project   = var.project_name
    ManagedBy = "terraform-bootstrap"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "expire-noncurrent-state-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "terraform_state_tls_only" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]

    resources = [
      aws_s3_bucket.terraform_state.arn,
      "${aws_s3_bucket.terraform_state.arn}/*",
    ]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  policy = data.aws_iam_policy_document.terraform_state_tls_only.json
}
```

- [ ] **Step 4: Add outputs**

```hcl
# terraform/bootstrap/outputs.tf

output "state_bucket_name" {
  description = "Name of the S3 bucket that holds Terraform state for the main stack."
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_region" {
  description = "Region the Terraform state bucket lives in."
  value       = var.aws_region
}
```

- [ ] **Step 5: Format and validate**

Run: `terraform fmt -check`
Expected: no output, exit code `0`.

Run: `terraform validate`
Expected: `Success! The configuration is valid.`

- [ ] **Step 6: Run the test suite to verify it passes**

Run: `terraform test`
Expected: `Success! 5 passed, 0 failed.`

- [ ] **Step 7: Commit**

```bash
git add terraform/bootstrap/main.tf terraform/bootstrap/outputs.tf terraform/bootstrap/tests/state_bucket.tftest.hcl
git commit -m "terraform: add state bucket with versioning, encryption, and TLS-only policy"
```

---

### Task 3: Documentation and CLAUDE.md commands

**Files:**
- Create: `terraform/bootstrap/README.md`
- Modify: `CLAUDE.md` (Commands section)

- [ ] **Step 1: Create `terraform/bootstrap/README.md`**

```markdown
# Terraform bootstrap

Creates the S3 bucket used as the remote state backend for the main
infrastructure stack (a separate, later Terraform root module). This
module is applied **once, manually, before the main stack exists** —
it cannot use the backend it's creating.

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

## Tearing down

Because versioning is enabled, S3 won't let `terraform destroy` remove
the bucket while it still holds object versions — delete those first:

```bash
aws s3api delete-objects --bucket <bucket-name> --delete "$(
  aws s3api list-object-versions --bucket <bucket-name> \
    --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
```

Then:

```bash
cd terraform/bootstrap
terraform destroy
```

## Usage

Authenticates via IAM Identity Center (SSO) under the `rearc-quest`
profile. One-time setup: `aws configure sso --profile rearc-quest`.

```bash
cd terraform/bootstrap
aws sso login --profile rearc-quest  # refresh SSO credentials
terraform init
terraform test    # runs tests/state_bucket.tftest.hcl against a mocked
                   # AWS provider — no credentials or cost required
terraform plan     # requires the rearc-quest SSO profile above
terraform apply    # creates the real S3 bucket
```

## Wiring up the main stack

Once applied, note the `state_bucket_name` output and use it in the main
stack's backend configuration:

```hcl
terraform {
  backend "s3" {
    bucket       = "<state_bucket_name output>"
    key          = "rearc-quest/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # native S3 locking, no DynamoDB table needed
  }
}
```
```

- [ ] **Step 2: Update CLAUDE.md's Commands section**

In [CLAUDE.md](../../../CLAUDE.md), find this paragraph in the `## Commands` section:

```
There is no lint or test tooling configured in the seed repo (`package.json` has no `lint`/`test` scripts). Any lint/test tooling for IaC, Dockerfiles, or new app code added during this project should be documented here as it's introduced.
```

Replace it with:

```
There is no lint or test tooling configured for the Node app in the seed repo (`package.json` has no `lint`/`test` scripts).

### Terraform (state bootstrap)

Authenticates via IAM Identity Center (SSO) under the `rearc-quest` profile — run `aws sso login --profile rearc-quest` to refresh credentials before `plan`/`apply`.

```bash
cd terraform/bootstrap
terraform init      # install aws provider
terraform fmt -check
terraform validate
terraform test      # mocked AWS provider — no credentials or cost required
terraform plan       # requires the rearc-quest SSO profile above
terraform apply      # one-time, manual — creates the real state bucket
```
```

- [ ] **Step 3: Commit**

```bash
git add terraform/bootstrap/README.md CLAUDE.md
git commit -m "docs: document Terraform bootstrap usage and commands"
```

---

### Task 4: Manual verification (not automated)

This task is **not** run by an agent — it creates a real AWS resource and requires the user's own AWS credentials.

- [ ] **Step 1: User refreshes SSO credentials and reviews the plan**

The user runs, from `terraform/bootstrap/`:

```bash
aws sso login --profile rearc-quest
terraform plan
```

and reviews that exactly one `aws_s3_bucket` and its associated versioning/lifecycle/encryption/public-access-block/policy resources are planned for creation — nothing else.

- [ ] **Step 2: User applies**

```bash
terraform apply
```

confirms the plan, and records the `state_bucket_name` output for use when the main stack's backend is configured in a later plan.

- [ ] **Step 3: User confirms the PR is ready**

No commit needed for this task — it's a real-world action, not a repo change. Once done, the PR for this branch can be opened for review.
