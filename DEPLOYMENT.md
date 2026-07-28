# Deployment

Terraform IaC for this submission lives under `terraform/`, starting
with [`terraform/bootstrap/`](terraform/bootstrap/README.md) which
provisions the S3 bucket used for the main stack's remote state. The
main stack itself (deploying the app, load balancer, and TLS) is a
separate, later piece of work.

## Architecture

The seed app (`src/000.js`) is a single Express process that shells out to
five opaque Go binaries in `bin/` via `child_process.exec()` — a local
subprocess spawn, not a network call. That makes it a monolith: one
container image holds the Node app and all the binaries together, with
no natural frontend/backend split to exploit architecturally.

### Design choices

- **Compute: EKS + Helm**, over ECS Fargate. Both are equally
  enterprise-standard; EKS was chosen to demonstrate Kubernetes/Helm
  depth relevant to this role, at the cost of more infrastructure surface
  (cluster, node group or Fargate profile, IRSA, ingress controller) than
  ECS would need for an app this small.
- **Networking:** a dedicated VPC (not the account default), spanning at
  least two AZs, with public subnets for the ALB and NAT gateways and
  private subnets for the EKS nodes/pods — the VPC CNI assigns pod IPs
  from the private subnet CIDR directly, so nodes never need a public IP.
  A single shared NAT gateway vs. one per AZ is a cost-vs-availability
  tradeoff left for the networking chunk to decide explicitly rather than
  default silently.
- **Ingress/load balancing:** the AWS Load Balancer Controller (installed
  via Helm) provisions an ALB from a Kubernetes `Ingress` resource. This
  satisfies the `/loadbalanced` check the same way an ALB would in an ECS
  design — by adding `X-Forwarded-*` headers to the request the app sees.
- **TLS:** a real domain is available, so TLS uses a public ACM
  certificate with Route 53 DNS validation, referenced on the Ingress via
  annotation — a browser-trusted cert for `/tls`, not a self-signed one.
- **Secrets:** `SECRET_WORD` lives in AWS Secrets Manager (chosen over SSM
  Parameter Store for the rotation story, at ~$0.40/mo) and is synced into
  the pod at runtime — never baked into the image — satisfying
  `/secret_word` while matching the repo's "inject at runtime" standard.

### Request flow

```mermaid
flowchart TB
    Client((Client)) -->|HTTPS| R53[Route 53]
    R53 --> ALB[Application Load Balancer]
    ACM[ACM Certificate] -.TLS termination.-> ALB

    subgraph EKS["EKS Cluster"]
        AWSLBC[AWS Load Balancer Controller] -.provisions.-> ALB
        ALB --> Ingress
        Ingress --> Svc[Service]
        Svc --> Pod["Pod (Node + Go binaries, one container)"]
        ESO[External Secrets Operator] --> Pod
    end

    SM[Secrets Manager: SECRET_WORD] --> ESO
    ECR[ECR Repository] -.image pull.-> Pod
```

### Rollout

Built incrementally as separate branches/PRs: containerize the app →
push to ECR → networking foundation → EKS cluster → ingress path → TLS →
secrets wiring → app Helm chart → final docs pass. Each stage is verified
against its corresponding quest route (see **Verifying each quest stage**
in `CLAUDE.md`) before the next is built on top of it.
