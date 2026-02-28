# Rails Health API — Production Deployment on AWS

A production-ready **Ruby on Rails API** deployed on **AWS** using **Docker**, **Terraform**, **ECS Fargate**, and **GitHub Actions CI/CD**.

This repo is intentionally small on “app features” and heavy on “platform practices” — the goal is to show how to ship and operate a containerized API in a real AWS environment with secure networking, HTTPS, WAF, and automated deployments.

---

## Live Endpoint

**https://api.baggam.com/health**

Example response:

```json
{ "status": "ok" }
```

---

## Architecture

```
Internet
   │
   ▼
api.baggam.com
   │
   ▼
DNS (GoDaddy)
   │
   ▼
AWS WAF
   │
   ▼
Application Load Balancer (HTTPS :443)
   │
   ▼
Target Group
   │
   ▼
ECS Fargate Service
   │
   ▼
Docker Container (Rails API)
```

---

## Key Features

### Infrastructure as Code (Terraform)
All AWS infrastructure is provisioned using **Terraform** (no manual console setup).

**Resources include:**
- VPC
- Public & Private Subnets
- Internet Gateway
- NAT Gateway
- ECS Cluster
- ECS Service (Fargate)
- Application Load Balancer
- ECR Repository
- ACM SSL Certificate
- AWS WAF
- Security Groups
- ECS Auto Scaling

### Containerized Application
The Rails API is packaged as a Docker container and stored in **Amazon ECR**.

### ECS Fargate Deployment
Runs on **ECS Fargate**, providing:
- Serverless container runtime
- Built-in scaling primitives
- Managed infrastructure (no EC2 nodes to manage)

### HTTPS with Custom Domain
Accessible over TLS via:
- **AWS ACM** certificate
- **ALB HTTPS listener (443)**

### Web Application Firewall (WAF)
WAF is attached to the ALB and configured with managed protections such as:
- AWS Managed Common Rule Set
- SQL injection protections
- XSS protections

### Auto Scaling
The ECS service can scale based on:
- CPU utilization
- ALB request count

Example scaling behavior:

| Traffic | Containers |
|---|---|
| Low | 2 |
| Medium | 3–4 |
| High | up to 6 |

---

## CI/CD Pipeline (GitHub Actions)

Deployments are automated via GitHub Actions.

**Flow**
```
Push to main
   │
   ▼
Build Docker Image
   │
   ▼
Push to Amazon ECR
   │
   ▼
Register new ECS task definition
   │
   ▼
Update ECS Service
   │
   ▼
Wait for deployment
   │
   ▼
Run health check
```

Workflow file:
- `.github/workflows/deploy.yml`

---

## Repository Structure

```
repo/
 ├── app/                      # Rails API
 │   ├── Dockerfile
 │   └── application code
 │
 ├── terraform/
 │   ├── modules/
 │   │   ├── vpc/
 │   │   ├── ecs/
 │   │   ├── alb/
 │   │   ├── ecr/
 │   │   └── waf/
 │   │
 │   └── environments/
 │       └── prod/
 │           ├── main.tf
 │           ├── variables.tf
 │           └── backend.tf
 │
 ├── .github/workflows/
 │   └── deploy.yml
 │
 └── README.md
```

---

## Run Locally (Docker)

### Prerequisites
- Docker installed
- Ruby/Rails not required (runs fully inside the container)

### Build
```bash
docker build -t rails-health-api ./app
```

### Run
```bash
docker run -p 3000:3000 \
  -e RAILS_MASTER_KEY=<your_master_key> \
  rails-health-api
```

### Test
```bash
curl http://localhost:3000/health
```

Expected:
```json
{"status":"ok"}
```

---

## Deploy Infrastructure (Terraform)

> Run Terraform from: `terraform/environments/prod`

### Initialize
```bash
terraform init
```

### Plan
```bash
terraform plan
```

### Apply
```bash
terraform apply
```

This provisions networking, ECS, ECR, ALB + TLS, WAF, and autoscaling.

---

## Deploy via CI/CD

A deployment is triggered automatically on pushes to the `main` branch:

```bash
git push origin main
```

GitHub Actions will:
1. Build the Docker image
2. Push the image to Amazon ECR
3. Register a new ECS task definition revision
4. Update the ECS service
5. Wait for rollout
6. Perform a health check

---

## Security Notes

This platform includes multiple layers of security by default:
- HTTPS via ACM certificate and ALB
- AWS WAF protections
- ECS tasks running in private subnets
- Security groups restricting inbound traffic to the ALB only
- Managed AWS services to reduce operational and patching burden

---

## Technologies Used

| Technology | Purpose |
|---|---|
| Ruby on Rails | API application |
| Docker | Containerization |
| AWS ECS Fargate | Container orchestration |
| AWS ECR | Container registry |
| Terraform | Infrastructure as Code |
| AWS ALB | Load balancing + TLS termination |
| AWS WAF | Security protection |
| GitHub Actions | CI/CD pipeline |

---

## Design Decisions (Interview-Friendly)

### Why ECS Fargate (instead of EC2 / EKS)?
- **Operational simplicity:** no node groups, no cluster upgrades, no patching worker nodes.
- **Good fit for stateless APIs:** straightforward task definitions and scaling.
- **Cost and clarity:** pay for CPU/memory requested per task and keep infra minimal.

### Why an ALB (instead of API Gateway)?
- **Native integration with ECS target groups** and health checks.
- **Straightforward HTTPS termination** with ACM.
- **Better fit for container routing patterns** and path-based routing if the service grows.

### Why Terraform modules?
- **Reusability:** environments can share the same building blocks (VPC, ECS, ALB, WAF).
- **Separation of concerns:** networking, compute, and edge concerns are isolated and testable.
- **Easier maintenance:** changes are localized and easier to review in PRs.

### Why WAF at the edge?
- **Cheap risk reduction:** blocks common attacks before they reach the service.
- **Defense-in-depth:** complements TLS, private networking, and least-privilege security groups.

### Why GitHub Actions for CI/CD?
- **Fast iteration:** tight integration with PRs, reviews, and main-branch protections.
- **Predictability:** pipeline runs are versioned with the repo.
- **Least moving parts:** no separate CI server to maintain.

---

## Future Improvements
- Blue/Green deployments (CodeDeploy) to reduce risk during rollouts
- CloudWatch dashboards + alarms (latency, 5xx, CPU/memory, target health)
- RDS integration (if persistence is needed)
- Redis caching
- Rate limiting via WAF and/or application middleware
- Observability stack (Datadog / Prometheus / OpenTelemetry)

---

## Author
**Geethanand Baggam**  
Cloud / DevOps enthusiast focused on building production-grade infrastructure.
