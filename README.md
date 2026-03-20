# CloudOpsHub — DevOps Project 3 (Group F)

A Docker + GitOps + Continuous Delivery pipeline on AWS Free Tier.

## Architecture
- Frontend: React app served via NGINX (Docker)
- Backend: Node.js API (Docker)
- Database: MySQL on AWS RDS db.t2.micro
- Registry: AWS ECR
- CI/CD: GitHub Actions
- Deployment: GitOps via SSH deploy script
- Monitoring: Prometheus + Grafana on EC2

## AWS Free Tier Strategy
- One t2.micro EC2 for both Dev and Staging (different ports)
- NGINX replaces AWS ALB (saves ~$20/month)
- Public subnets only — no NAT Gateway (saves ~$32/month)
- RDS stopped when not testing

## Repo Structure
- terraform/   — Infrastructure as Code
- docker/      — Dockerfiles for all services
- gitops/      — Docker Compose configs synced by CI/CD
- monitoring/  — Prometheus + Grafana config
- scripts/     — Deploy scripts
