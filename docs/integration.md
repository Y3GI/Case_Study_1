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

## 4. Prometheus to Database (Aurora MySQL)

* **Authentication:** The `mysqld-exporter` sidecar container uses a `.my.cnf` configuration file containing database credentials.

* **Network Path:** ECS Task (Port 3306) -> RDS Proxy Security Group -> Aurora Database.

* **Integration:** The exporter connects to the RDS Proxy. The proxy handles connection pooling and is configured with `require_tls = false` for internal VPC traffic, removing the need for complex container-level SSL certificate management.