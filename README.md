# Case_Study_1
# 🛡️ Secure Serverless Monitoring Stack

## Overview
This repository contains the Infrastructure as Code (IaC) to deploy a highly secure, enterprise-grade serverless web application and monitoring stack on AWS. Built completely with Terraform, this project features a multi-VPC architecture connected via AWS Transit Gateway, with compute and database resources locked in an air-gapped private network. 

**Key Feature:** The application is exposed to the internet via an Application Load Balancer (ALB) in a Public VPC, which securely routes traffic through a Transit Gateway to a Lambda function in a fully Private VPC. CI/CD deployments are handled via GitHub Actions authenticated through short-lived OpenID Connect (OIDC) tokens.

## 🏗️ Architecture & Tech Stack
* **Infrastructure as Code:** Terraform
* **Networking:** Multi-VPC (Public & Private), AWS Transit Gateway, VPC Endpoints
* **Ingress:** Application Load Balancer (ALB)
* **Compute/App:** AWS Lambda (Private VPC)
* **Database:** Amazon Aurora MySQL, AWS RDS Proxy
* **Monitoring (ECS Fargate):** Prometheus, Grafana, native AWS CloudWatch Insights
* **CI/CD:** GitHub Actions with AWS OIDC integration

## 🚀 Deployment Instructions

This project requires a two-phase deployment: bootstrapping the global state/authentication, followed by the automated pipeline deployment.

### Phase 1: Bootstrapping Global Resources (Local)
Before the pipeline can run, you must provision the S3 backend for Terraform state and the OIDC IAM Roles for GitHub Actions.
1. Navigate to the global configuration directory:
   ```bash
   cd global

2. Initialize and apply the global infrastructure:
    ```bash
    terraform init
    terraform apply

### Phase 2: Application & Monitoring Deployment (Pipeline)

Once the global OIDC role and S3 state bucket exist, the rest of the infrastructure is deployed automatically via GitHub Actions.

1. Fork or clone this repository to your GitHub account.

2. Go to your repository Settings > Secrets and variables > Actions.

3. Add your required AWS environment variables (e.g., Target AWS Account ID, Region). Note: AWS Access Keys are NOT required due to OIDC.

4. Trigger the deployment pipeline via the GitHub Actions tab.