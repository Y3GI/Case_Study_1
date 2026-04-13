# 🔌 Integration & IAM Guide

This document explains how the distinct components of the architecture authenticate and communicate across network boundaries.

## 1. External Ingress to Compute (ALB to Lambda)

* **Network Path:** Internet -> IGW -> Public VPC -> ALB -> AWS Transit Gateway -> Private VPC -> AWS Lambda.

* **Integration:** The ALB in the Public VPC uses the Transit Gateway as a routing target. The Lambda function is invoked securely as an ALB target group. The ALB handles all TLS termination and client connections.

## 2. CI/CD Pipeline Authentication (GitHub Actions to AWS)

* **Authentication:** GitHub Actions uses an OIDC identity provider trust relationship. 

* **Integration Flow:** 
    1. The pipeline requests a JSON Web Token (JWT) from GitHub.
    2. AWS validates the JWT against the OIDC provider created in the `global` module.
    3. If the repository and branch match the trust policy, AWS issues temporary STS credentials to the pipeline to execute the Terraform apply.

## 3. Monitoring Stack to AWS APIs (Grafana & CloudWatch)

* **Authentication:** Grafana authenticates via the ECS Task Execution Role.

* **IAM Policies:** `logs:GetLogEvents`, `cloudwatch:ListMetrics`, `cloudwatch:GetMetricData`.

* **Network Path:** ECS Task -> `.logs` and `.monitoring` VPC Interface Endpoints -> AWS Control Plane. Traffic never leaves the internal AWS network.

## 4. ECS Monitoring Stack to AWS Services (VPC Endpoints)

* **Network Path:** ECS Task -> VPC Interface Endpoints (ECR, CloudWatch Logs, CloudWatch Metrics, STS, OAM) -> AWS Control Plane.

* **Integration:** ECS tasks pull container images (`grafana`, `prometheus`, `loki`, `matrix_exporter`, `alloy`) from ECR via the `ecr.api` and `ecr.dkr` endpoints. CloudWatch Logs are streamed via the `logs` endpoint, and metrics are published via the `monitoring` endpoint. All communication remains within the AWS internal network.

* **IAM Policies:** ECS Task Execution Role includes `ecr:GetAuthorizationToken`, `logs:CreateLogStream`, `logs:PutLogEvents`. ECS Task Role includes `cloudwatch:PutMetricData`, `logs:PutLogEvents`.

## 5. Prometheus (Sidecar) to Database (Aurora MySQL)

* **Authentication:** The `prometheusexporter` (MySQL exporter) sidecar container uses database credentials from AWS Secrets Manager.

* **Network Path:** ECS Task -> RDS Proxy Security Group -> Aurora Database.

* **Integration:** The exporter connects to the RDS Proxy endpoint. The proxy handles connection pooling and is configured with `require_tls = false` for internal VPC traffic, removing the need for complex container-level SSL certificate management.

## 6. SNS Integration (Grafana Alerts to SOAR)

* **Network Path:** ECS Grafana Task -> SNS VPC Endpoint -> AWS SNS -> SOAR Lambda Function.

* **Integration:** Grafana alert rules send notifications to the SNS topic (`{env}-grafana-alerts`) created by the SOAR module. The SNS endpoint in the private VPC enables secure alert delivery without internet routing. The SNS topic has two subscriptions: one to the SOAR responder Lambda (for automated incident response) and one to the configured email address (for human notification).