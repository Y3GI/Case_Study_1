# 📐 Technical Design & Architecture Justification

This document outlines the core architectural decisions made during the development of this stack, specifically regarding network security, ingress routing, and CI/CD authentication.

## 1. Edge Security & Ingress: ALB -> Transit Gateway -> Lambda

**Decision:** The Application Load Balancer (ALB) is placed in a dedicated Public VPC. Traffic is routed through an AWS Transit Gateway to the application Lambda function, which resides in a strictly Private VPC.

* **Justification:** Defense in depth. By isolating the compute layer (Lambda) in a private network, it is mathematically impossible for the application to be directly accessed or scanned from the public internet. The ALB acts as the sole ingress point, allowing for centralized WAF (Web Application Firewall) rules, TLS termination, and traffic inspection before traffic ever crosses the Transit Gateway into the secure application environment.

## 2. CI/CD Security: OpenID Connect (OIDC) vs. IAM Users

**Decision:** GitHub Actions pipelines authenticate to AWS using OpenID Connect (OIDC) to assume an IAM Role, rather than using long-lived IAM User Access Keys stored as GitHub Secrets.

* **Justification:** Security best practices. Long-lived static credentials are a major attack vector if leaked. OIDC allows GitHub to request short-lived, temporary STS security tokens that expire automatically. The OIDC provider and required S3 state bucket are bootstrapped separately in a `global` Terraform module to ensure a secure foundation before application deployment.

## 3. Network Isolation: VPC Endpoints vs. NAT Gateway

**Decision:** The Private VPC does not utilize a NAT Gateway. All outbound AWS API calls from the ECS monitoring stack are handled via VPC Interface Endpoints.

* **Justification:** Cost and absolute isolation. A NAT Gateway introduces a potential egress vector to the public internet and costs ~$32/month. By using specific VPC Endpoints (`logs`, `monitoring`, `sts`), the containers securely communicate with AWS Control Plane APIs over the internal AWS backbone. 

## 4. Module Separation: ECS in Monitoring

**Decision:** The ECS Fargate cluster hosting Prometheus and Grafana is structurally separated into the `monitoring` Terraform module rather than a general `compute` module.

* **Justification:** Separation of concerns. The lifecycle, scaling rules, and IAM permissions of the observability stack differ vastly from the application compute layer (Lambda). Keeping ECS scoped to the monitoring module prevents permission scope creep.

## 5. Observability: ECS-hosted PLG Stack vs. EC2/Traditional

**Decision:** The monitoring stack (Prometheus, Loki, Grafana) is deployed as ECS Fargate tasks in the Private VPC, rather than on EC2 instances.

* **Justification:** ECS Fargate eliminates the need to manage underlying infrastructure, reducing operational overhead. Containers are deployed within the Private VPC, utilizing VPC Interface Endpoints for secure communication with AWS services (ECR, CloudWatch Logs, CloudWatch Metrics). The architecture supports multi-region container images stored in ECR with automatic log aggregation to CloudWatch.

## 6. Observability: VPC Endpoints for ECS Monitoring Stack

**Decision:** The ECS monitoring cluster communicates with AWS services exclusively through interface and gateway VPC Endpoints (ECR, CloudWatch Logs, CloudWatch Metrics, STS, OAM, S3, SNS).

* **Justification:** Interface Endpoints (`ecr.api`, `ecr.dkr`, `logs`, `monitoring`, `sts`, `oam`) enable the ECS tasks to pull container images and send telemetry without internet access. This maintains the air-gapped private network while providing full observability capabilities.