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
- **Key deliverables:** a PR workflow that runs `terraform fmt -check`,
  `terraform validate`, and `terraform test` (mocked provider) against
  both `terraform/bootstrap/` and the main app stack, plus `terraform
  plan` against real AWS for the main stack (review only, no apply); a
  merge-to-`main` workflow that runs `terraform apply` for the **main app
  stack only**, via a least-privilege OIDC role scoped to that stack's
  resources — `terraform/bootstrap/` is explicitly excluded from any CI
  apply and stays a manual, human-only operation (it bootstraps the very
  state backend these CI runs depend on, so it can't depend on them in
  return); a workflow that builds the Docker image (and runs `docker
  build` as a smoke test) once the Dockerfile exists in Step 1.
- **Depends on:** nothing — can land first, ahead of the app-specific
  stages, and is the reason it's numbered 0 rather than appended at the
  end.
- **Verifies:** CI runs green on its own PR; no quest route to check.
- **Follow-up:** once this merges, `CLAUDE.md`'s Terraform standards
  bullet (currently "never run by an agent or CI — this repo has no CI")
  needs updating to describe the apply-on-merge model for the main stack.

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
- **Key deliverables:** EKS cluster — including KMS envelope encryption
  for Kubernetes Secrets (`encryption_config` block, set at cluster
  creation so Step 7's ESO-materialized Secrets are covered from the
  start) — node group or Fargate profile, IRSA (`aws-auth`/access
  entries), cluster autoscaler consideration.
- **Depends on:** Step 3.
- **Verifies:** no quest route yet; `kubectl get nodes` healthy.

### Step 5: Ingress path

- **Goal:** get traffic from an ALB into a pod, satisfying the
  load-balanced check.
- **Key deliverables:** AWS Load Balancer Controller (via Helm), and an
  `Ingress`/`Service`/`Deployment` routing to the **real app image**
  (not a placeholder) — `/loadbalanced` depends on the app's own
  header-echo logic, so nothing generic can satisfy it. This is why the
  step depends on Step 2 (ECR). Step 8 later consolidates these
  hand-wired manifests into a proper parameterized Helm chart.
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
- **Key deliverables:** Secrets Manager secret; **External Secrets
  Operator (ESO)** installed via Helm to sync it into a native
  Kubernetes `Secret`, consumed via `envFrom`/`secretKeyRef` (matches the
  app's env-var expectation with no init-container/wrapper plumbing,
  unlike the Secrets Store CSI driver's file-mount approach); IRSA
  scoping for ESO's IAM role. Relies on the KMS envelope encryption
  enabled on the cluster in Step 4 to keep the resulting Secret encrypted
  at rest in etcd.
- **Depends on:** Step 4 (needs IRSA + the cluster's `encryption_config`);
  can proceed in parallel with Steps 5–6.
- **Verifies:** `/secret_word`, on the cluster.

### Step 8: App Helm chart

- **Goal:** consolidate the hand-wired `Deployment`/`Service`/`Ingress`
  from Step 5 into a proper, parameterized Helm chart.
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
