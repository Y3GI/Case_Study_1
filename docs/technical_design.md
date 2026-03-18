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

## 5. Observability: Native CloudWatch vs. Third-Party Exporters

**Decision:** We utilize Grafana's native CloudWatch plugin to monitor AWS Lambda metrics, actively choosing to remove YACE (Yet Another CloudWatch Exporter).

* **Justification:** YACE relies on the AWS Resource Groups Tagging API, which *does not support VPC Endpoints*. Because our Private VPC prohibits internet access via NAT Gateway, YACE cannot resolve the Tagging API. Grafana's native integration routes perfectly through our `.monitoring` VPC endpoint, achieving the same result natively and securely.