# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

This is the **Rearc Quest** — a take-home cloud engineering assessment (see [README.md](README.md) for the full brief). The repo currently contains only the seed webapp; everything else (IaC, Dockerfiles, CI, deployment) is work this candidate is building on top of it as a demonstration of AWS/Terraform/deployment best practices for a Lead Cloud Engineer role. Solution-specific documentation lives in [DEPLOYMENT.md](DEPLOYMENT.md), not README.md (see **Docs** under Engineering standards below).

The seed app is a tiny Express server (`src/000.js`) that shells out to precompiled Go binaries in `bin/` to answer a series of "is this stage done yet?" checks. Each binary is opaque (no source included) — treat them as black boxes and don't try to decompile or modify them.

## Commands

```bash
npm install     # install dependencies (express only)
npm start       # run the app locally on :3000 (node src/000.js)
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

### Verifying each quest stage

The app exposes one route per quest stage. Use these to confirm a stage actually works end-to-end before moving to the next one — don't advance on faith:

```bash
curl http(s)://<host>[:port]/               # index page, contains the SECRET_WORD
curl http(s)://<host>[:port]/docker         # confirms running inside Docker
curl http(s)://<host>[:port]/secret_word    # confirms SECRET_WORD env var was injected correctly
curl http(s)://<host>[:port]/loadbalanced   # confirms traffic is passing through a load balancer
curl http(s)://<host>[:port]/tls            # confirms TLS termination
```

## Architecture

`src/000.js` is the entire app. Each route does the same thing: `child_process.exec()` a numbered binary in `bin/` and return its stdout as the response body. Routes for `/loadbalanced`, `/tls`, and `/secret_word` also forward the raw request headers (JSON-stringified) as an argv to the binary, since those checks depend on header/connection state (e.g. `X-Forwarded-*`, TLS info) that only the binary can inspect.

| Route | Binary | Checks |
|---|---|---|
| `/` | `bin/001` | Index page, reveals `SECRET_WORD` |
| `/aws` | `bin/002` | AWS-specific check (not in the public stage list, but wired up) |
| `/docker` | `bin/003` | App is running inside a container |
| `/loadbalanced` | `bin/004` | Request passed through a load balancer |
| `/tls` | `bin/005` | Request arrived over TLS |
| `/secret_word` | `bin/006` | `SECRET_WORD` env var matches the value shown on `/` |

Since the binaries are static/opaque, the effective "spec" for each stage is: get the binary invoked with the right runtime conditions (containerized, behind a load balancer, behind TLS, with the right env var) and let it self-report success.

`terraform/bootstrap/` is a standalone Terraform root module with its own **local** state (deliberately not remote, since it creates the S3 bucket a remote backend would need). It's applied once, manually, to produce the state bucket that the *main* infrastructure stack — a separate, later piece of work — will use for its own remote state backend.

## Engineering standards for this project

This repo is a portfolio piece for a Lead Cloud Engineer interview — the IaC, deployment approach, and history should read as production-grade, not a quick hack to pass the checks.

- **Commit granularity**: commit frequently, at meaningful checkpoints (e.g. "add ECS task definition", "wire up ALB target group", "enable TLS on listener") rather than in large batches. The commit history itself is part of what's being evaluated — it should show incremental, reviewable progress through each quest stage.
- **Verify before advancing**: after standing up infrastructure for a stage, hit the corresponding check route (see above) and confirm it passes before building the next stage on top of it.
- **Terraform**: pin provider versions, run `terraform fmt`/`terraform validate` (and `terraform plan` review) before every apply, keep state and secrets out of version control, and structure resources so the "given more time" writeup can point at specific, deliberate tradeoffs rather than omissions; `terraform test` against a mocked AWS provider is the primary correctness check before any real apply, and `terraform apply` against real AWS is a human-only, manual step — never run by an agent or CI (this repo has no CI).
- **Terraform bootstrap's local state**: `terraform/bootstrap/`'s local `terraform.tfstate` is a deliberate, gitignored exception to "keep state out of version control" above (it can't use a remote backend since it creates that backend) — don't "fix" this by adding a remote backend to the bootstrap module itself. Its `.terraform.lock.hcl` is intentionally committed (unlike `.terraform/` and `*.tfstate`, which are gitignored).
- **Docker**: build `FROM node:10` or later per the brief; inject `SECRET_WORD` at container runtime (`docker run -e` / task definition env var), never bake it into the image.
- **Secrets/certs**: locally-generated TLS certs and any credentials belong outside git — use `.gitignore` and a secrets manager or `-var-file` pattern, not committed files.
- **Docs**: never edit root `README.md` — it's the interviewer's original brief, kept as-is for their reference. All solution documentation (how to reproduce the deployment, how to tear it down, design tradeoffs) goes in root `DEPLOYMENT.md` instead, kept current as work lands — the brief explicitly grades submissions on how close they read to a finished customer deliverable.
- **Branching/PRs**: every logical change gets its own branch off `master`, opened as a PR for review rather than committed straight to `master`. Don't stack unrelated changes on one branch. Plans are authored and executed via `superpowers` (`writing-plans` / `executing-plans` / `subagent-driven-development`); a plan is decomposed into PR-sized chunks of tasks per the global CLAUDE.md rule, and each chunk is its own branch/PR — one plan commonly spans several PRs, not just one. Each task within a chunk still pauses for self-review and is presented as its own commit before moving on (also per global CLAUDE.md).

## Keeping this file current

Treat this file as living documentation, not a one-time snapshot:

- When new tooling is added (Terraform, Dockerfiles, CI, a test runner, linters), update **Commands** with the real invocations (`terraform init/plan/apply`, `docker build/run`, etc.) and update **Architecture** if the new pieces change how the app is structured or deployed.
- When corrected on approach (e.g. "don't do X", "always do Y this way"), add a short rule under **Engineering standards** capturing the correction, so it isn't relearned next session.
- Keep additions terse and specific — one line/bullet per fact, no restating things already covered elsewhere in this file.
