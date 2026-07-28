# Deployment Roadmap

> This is an **index of future plans**, not an executable plan itself — it
> has no checkbox tasks. Each step below gets its own detailed
> implementation plan (authored via `superpowers:writing-plans` when that
> step is actually started) and its own branch/PR, per `CLAUDE.md`'s
> branching convention. Do not dispatch `subagent-driven-development` or
> `executing-plans` against this document directly.

**Source of truth for the "why":** `DEPLOYMENT.md` (Architecture / Design
choices / Rollout sections) — this document only sequences the *what* and
*when*, it doesn't restate the architecture rationale.

## Roadmap

### Step 0: CI/CD pipelines (GitHub Actions)

- **Goal:** stand up the automated review gate every later PR runs
  through, before building app-specific infrastructure on top of it.
- **Key deliverables:** a workflow that runs `terraform fmt -check`,
  `terraform validate`, and `terraform test` (mocked provider) against
  `terraform/bootstrap/` and the future main stack on every PR; a
  workflow that builds the Docker image (and runs `docker build` as a
  smoke test) once the Dockerfile exists in Step 1. No `terraform plan`
  against real AWS and no `terraform apply`/deploy step — those stay
  human-only per `CLAUDE.md`'s existing rule.
- **Depends on:** nothing — can land first, ahead of the app-specific
  stages, and is the reason it's numbered 0 rather than appended at the
  end.
- **Verifies:** CI runs green on its own PR; no quest route to check.
- **Follow-up:** once this merges, `CLAUDE.md`'s "this repo has no CI"
  aside (in the Terraform engineering-standards bullet) needs updating.

### Step 1: Containerize the app

- **Goal:** produce a working Docker image for the existing app, verified
  locally, with no AWS dependency yet.
- **Key deliverables:** `Dockerfile` (Debian-based Node image — the
  opaque `bin/*` binaries are likely glibc-linked, so Alpine/musl is
  avoided), `.dockerignore`, `SECRET_WORD` injected via `docker run -e`
  only.
- **Depends on:** Step 0 (so the Dockerfile gets a CI smoke-build from
  the start).
- **Verifies:** `/docker`, `/secret_word` (against a locally run
  container).

### Step 2: Push image to ECR

- **Goal:** get the verified image into a private registry EKS can pull
  from.
- **Key deliverables:** ECR repository resource (Terraform), lifecycle
  policy (e.g. expire untagged images), build/push instructions in
  `DEPLOYMENT.md`.
- **Depends on:** Step 1.
- **Verifies:** no new quest route; confirms the pushed image still runs
  (`docker run` against the pulled-back image).

### Step 3: Networking foundation

- **Goal:** stand up the VPC the cluster and load balancer will live in.
- **Key deliverables:** dedicated VPC (≥2 AZs), public subnets (ALB, NAT
  gateways), private subnets (EKS nodes/pods), security groups sized for
  EKS. Single shared NAT vs. one per AZ is a cost/availability tradeoff
  to decide explicitly in this chunk's plan, not default silently.
- **Depends on:** Step 0 (CI validates the new Terraform); independent of
  Steps 1–2 otherwise.
- **Verifies:** no quest route; `terraform plan`/`apply` succeeds and
  subnets/route tables look correct.

### Step 4: EKS cluster

- **Goal:** stand up the control plane and compute for the app.
- **Key deliverables:** EKS cluster, node group or Fargate profile, IRSA
  (`aws-auth`/access entries), cluster autoscaler consideration.
- **Depends on:** Step 3.
- **Verifies:** no quest route yet; `kubectl get nodes` healthy.

### Step 5: Ingress path

- **Goal:** get traffic from an ALB into a pod, satisfying the
  load-balanced check.
- **Key deliverables:** AWS Load Balancer Controller (via Helm),
  `Ingress` resource routing to a placeholder or real Service.
- **Depends on:** Steps 2 and 4.
- **Verifies:** `/loadbalanced`.

### Step 6: TLS

- **Goal:** terminate TLS on the ALB with a browser-trusted cert.
- **Key deliverables:** ACM certificate, Route 53 DNS validation, cert
  wired onto the ALB via Ingress annotation.
- **Depends on:** Step 5.
- **Verifies:** `/tls`.

### Step 7: Secrets

- **Goal:** get `SECRET_WORD` into the running pod without baking it into
  the image, end-to-end on the cluster (not just locally per Step 1).
- **Key deliverables:** Secrets Manager secret, sync mechanism (External
  Secrets Operator vs. Secrets Store CSI driver — decide explicitly in
  this chunk), IRSA scoping for the sync.
- **Depends on:** Step 4 (needs IRSA); can proceed in parallel with
  Steps 5–6.
- **Verifies:** `/secret_word`, on the cluster.

### Step 8: App Helm chart

- **Goal:** replace any placeholder Service/Ingress from Step 5 with a
  proper chart deploying the real app image.
- **Key deliverables:** `Deployment`/`Service`/`Ingress` templates,
  `values.yaml`.
- **Depends on:** Steps 2, 5, 6, 7 (pulls the pieces together).
- **Verifies:** every quest route, end-to-end, through the real stack.

### Step 9: Docs pass

- **Goal:** leave `DEPLOYMENT.md` reading like a finished customer
  deliverable, per the repo's grading criteria.
- **Key deliverables:** full reproduce/tear-down instructions, a "given
  more time" tradeoffs section.
- **Depends on:** Step 8.
- **Verifies:** no quest route; documentation review only.

## Sequencing

Step 0 is independent and lands first. Steps 1–2 and Step 3 can proceed in
parallel (containerizing the app doesn't need the VPC). From Step 4
onward, each step depends on the ones noted above — Steps 5 and 7 can run
in parallel once Step 4 lands, both feeding into Step 8.

## Next step

Author the Step 0 (CI/CD) implementation plan via `superpowers:writing-plans`,
on its own branch (e.g. `ci-github-actions`), following the precedent set by
`docs/superpowers/plans/2026-07-28-terraform-bootstrap.md`.
