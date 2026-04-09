# Comprehensive Service Overview
## Case Study 1: Secure Serverless Monitoring Stack

**Document Date:** April 2026  
**Environment:** Development (eu-central-1)  
**Architecture Type:** Multi-VPC Serverless with ECS Monitoring Stack

---

## Table of Contents
1. [Certificates Module](#certificates-module)
2. [Networking Module](#networking-module)
3. [Storage Module](#storage-module)
4. [Monitoring Module](#monitoring-module)
5. [SOAR Module](#soar-module)
6. [Compute Module](#compute-module)

---

## Certificates Module

### Purpose
The Certificates module manages SSL/TLS certificate provisioning and distribution across the infrastructure using AWS Certificate Manager (ACM). It handles both server and client certificates for encrypted communication between services.

### Components

#### 1. **AWS ACM Server Certificate** (`aws_acm_certificate.server`)
- **Role:** Encryption certificate for server-to-client communication
- **Source:** Local certificate files stored in `modules/certificates/certs/server/`
- **Files Required:**
  - `server.key` - Private key
  - `server.crt` - Certificate body
  - `ca.crt` - CA certificate chain
- **Usage:** Applied to ALB listeners and secure endpoints
- **Tags:** Environment-specific naming (e.g., `dev-server-certificate`)

#### 2. **AWS ACM Client Certificate** (`aws_acm_certificate.client`)
- **Role:** Client authentication certificate for mutual TLS scenarios
- **Source:** Local certificate files stored in `modules/certificates/certs/client/`
- **Files Required:**
  - `client.key` - Private key
  - `client.crt` - Certificate body
  - `ca.crt` - CA certificate chain
- **Use Cases:** Service-to-service authentication, VPN client certificates

### Certificate Management

**Certificate Directory Structure:**
```
certs/
├── ca/
│   ├── ca.crt          # Certificate Authority certificate
│   └── ca.srl          # Certificate revocation list
├── server/
│   ├── server.key      # Server private key
│   └── server.crt      # Server certificate
└── client/
    ├── client.key      # Client private key
    └── client.crt      # Client certificate
```

### Variables
- `region` - AWS region for certification deployment
- `env` - Environment identifier (e.g., "dev")
- `tags` - Resource tags for billing and organization
- `email` - Contact email for certificate notifications

### Security Considerations
- Private keys are managed locally and must be kept secure
- Certificates are stored as code and should be rotated periodically
- Client certificates enable mutual TLS authentication
- Server certificate is used by the ALB for HTTPS traffic

### Dependencies
- None (foundational module)

### Output Exports
- Server certificate ARN
- Client certificate ARN
- Certificate metadata

---

## Networking Module

### Purpose
The Networking module establishes the foundational network infrastructure for the entire AWS deployment. It creates a multi-VPC architecture (Public and Private VPCs) connected via AWS Transit Gateway, enabling secure communication between internet-facing and air-gapped resources.

### Architecture Overview

**Network Topology:**
- **Public VPC** (10.1.0.0/16) - Contains internet-facing resources (ALB)
- **Private VPC** (10.2.0.0/16) - Contains compute and database resources
- **Transit Gateway** - Connects both VPCs for controlled inter-VPC routing

### Components

#### 1. **Virtual Private Clouds (VPCs)**

**Public VPC** (`aws_vpc.public`)
- **CIDR Block:** 10.1.0.0/16
- **Purpose:** Hosts internet-facing resources
- **DNS Support:** Enabled
- **DNS Hostnames:** Enabled (allows Route53 resolution)

**Private VPC** (`aws_vpc.private`)
- **CIDR Block:** 10.2.0.0/16
- **Purpose:** Hosts compute and database resources
- **DNS Support:** Enabled
- **DNS Hostnames:** Enabled

#### 2. **Internet Gateway** (`aws_internet_gateway.igw`)
- **Association:** Attached to Public VPC
- **Purpose:** Provides internet connectivity for resources in public subnets
- **Route:** Enables route to 0.0.0.0/0 (all internet traffic)

#### 3. **Subnets**

**Public Subnets (ALB Layer)**
- `alb_subnet1` (10.1.1.0/24, eu-central-1a)
- `alb_subnet2` (10.1.2.0/24, eu-central-1b)
- **Purpose:** Host ALB in multiple availability zones
- **Internet Access:** Direct via IGW

**Private Subnets (Application & Database Layer)**
- `subnet1` (10.2.1.0/24, eu-central-1a) - General private subnet
- `db_subnet1` (10.2.2.0/24, eu-central-1a) - Database tier
- `db_subnet2` (10.2.3.0/24, eu-central-1b) - Database tier (standby)
- `lambda_subnet1` (10.2.4.0/24, eu-central-1a) - Lambda execution
- `lambda_subnet2` (10.2.5.0/24, eu-central-1b) - Lambda execution (standby)

#### 4. **AWS Transit Gateway** (`aws_ec2_transit_gateway.main`)
- **Purpose:** Central hub for VPC-to-VPC connectivity
- **Features:**
  - Default route table association enabled
  - Default route table propagation enabled
  - DNS support enabled
  - VPN ECMP support enabled (for redundancy)

**Transit Gateway VPC Attachments:**

1. **Public VPC Attachment** (`aws_ec2_transit_gateway_vpc_attachment.public`)
   - Connects public ALB subnets to TGW
   - Subnets: alb_subnet1, alb_subnet2
   - Routes public VPC traffic through transit gateway

2. **Private VPC Attachment** (`aws_ec2_transit_gateway_vpc_attachment.private`)
   - Connects private database subnets to TGW
   - Subnets: db_subnet1, db_subnet2
   - Routes private VPC traffic through transit gateway

#### 5. **Transit Gateway Routes**

**Public-to-Private Route** (`aws_route.tgw_public_to_private`)
- **From:** Public VPC route table
- **Destination:** 10.2.0.0/16 (Private VPC CIDR)
- **Via:** Transit Gateway main
- **Effect:** Allows ALB in public VPC to route traffic to Lambdas in private VPC

**Private-to-Public Route** (`aws_route.tgw_private_to_public`)
- **From:** Private VPC route table
- **Destination:** 10.1.0.0/16 (Public VPC CIDR)
- **Via:** Transit Gateway main
- **Effect:** Allows private resources to initiate connections to ALB

#### 6. **VPC Endpoints**
- Provides private connectivity to AWS services (S3, DynamoDB, etc.)
- Reduces data egress costs
- Enhances security by avoiding internet routing

#### 7. **Client VPN Endpoint** (referenced in firewall.tf)
- **Purpose:** Provides remote VPN access to the private VPC
- **Authorization:** VPC-wide access to private network CIDR (10.2.0.0/16)
- **Protocol:** Client VPN (OpenVPN-based)

#### 8. **Network Security Groups** (defined in sec_groups.tf)
- Managed separately to segment inbound/outbound rules
- Associated with: ALB, Lambda, RDS, Monitoring resources

#### 9. **Route Tables & Routes** (defined in routes.tf)
- **Public Route Table:** Routes internet traffic via IGW
- **Private Route Table:** Routes inter-VPC traffic via Transit Gateway
- **Subnet Associations:** Explicit route table assignments

### Variables

**Sizing & CIDR Configuration:**
- `public_vpc_cidr` - Default: 10.1.0.0/16
- `private_vpc_cidr` - Default: 10.2.0.0/16
- `public_subnet_cidrs` - Map of ALB subnets with AZ assignments
- `private_subnet_cidrs` - Map of application/database subnets with AZ assignments

**Instance Types:**
- `vpc_instance_type` - Default: t3.micro (for NAT Gateway)

**Availability Zones:**
- `azs` - Default: ["eu-central-1a"]

**Common Variables:**
- `region` - AWS region (eu-central-1)
- `env` - Environment identifier (dev)
- `tags` - Resource tagging for organization
- `email` - Notification email

### Network Flow Examples

**Example 1: Client to Application**
```
Internet User
    ↓
ALB (10.1.x.x) [Public VPC, receives HTTPS on port 443]
    ↓ Transit Gateway
Lambda (10.2.4.x) [Private VPC, processes request]
    ↓
RDS Proxy (10.2.x.x) [Private VPC, returns data]
    ↓
ALB → User Response [HTTPS, port 443]
```

**Example 2: Remote Admin Access**
```
Admin Workstation
    ↓ OpenVPN
Client VPN Endpoint
    ↓
Private VPC (10.2.0.0/16)
    ↓
RDS, EC2 instances, monitoring stack
```

### Dependencies
- **Certificates Module** - Optional (VPN can use client certificates)

### Output Exports
- Public VPC ID
- Private VPC ID
- Public subnet IDs (for ALB)
- Private subnet IDs (for Lambda/RDS)
- Transit Gateway ID
- Security group IDs
- Route table IDs

### Security Features
- **Air-gapped Private VPC:** Database and compute resources are not directly accessible from internet
- **Multi-AZ Deployment:** DB and Lambda subnets span 2 availability zones for high availability
- **VPN Access:** Remote administrators can securely access private VPC
- **Transit Gateway Routing:** Controlled inter-VPC connectivity with centralized route management
- **DNS Resolution:** Private hosted zones support internal service discovery

---

## Storage Module

### Purpose
The Storage module provisions persistent data storage, database infrastructure, container registries, and secrets management. It provides MySQL database capabilities via Amazon Aurora, connection pooling through RDS Proxy, and secure credential management through AWS Secrets Manager.

### Components

#### 1. **Amazon Aurora MySQL Cluster** (`aws_rds_cluster.aurora_rds`)
- **Engine:** Aurora MySQL 8.0 (version 8.0.mysql_aurora.3.10.3)
- **Cluster Identifier:** `dev-aurora-cluster`
- **Database Name:** `aurora_db`
- **Master User:** `admin` (credentials stored in Secrets Manager)
- **Network:**
  - VPC Security Groups: Aurora-specific security group
  - DB Subnet Group: Spans private subnets in 2 AZs
  - Publicly Accessible: No (private network only)
- **Storage Encryption:** Disabled (can be enabled for production)
- **Backup:** Auto-generated snapshots, skip final snapshot on destroy
- **Tags:** Environment-specific naming (e.g., `dev-aurora-cluster`)

**Features:**
- Multi-AZ automatic failover within Aurora cluster
- Read replicas can be created for scaling read traffic
- Automated backups retained for 7 days (default)
- Performance Insights available (metrics)
- Native MySQL 8.0 compatibility

#### 2. **Aurora Cluster Instances** (`aws_rds_cluster_instance.cluster_instance`)
- **Deployment:** Configured as a map for scaling
- **Default Instance:**
  - Instance Class: `db.t3.medium`
  - Engine: Aurora MySQL 8.0
  - Publicly Accessible: No
- **Auto-replication:** Within Aurora cluster (synchronous)
- **Monitoring:** CloudWatch metrics for CPU, memory, connections
- **Automatic Failover:** Aurora handles failover between instances

**Instance Scaling:**
```hcl
aurora_instances = {
  "instance-1" = {
    instance_class = "db.t3.medium"
  }
}
```

#### 3. **RDS Proxy** (`aws_db_proxy.rds_proxy`)
- **Purpose:** Connection pooling and database connectivity management
- **Name:** `dev-rds-proxy`
- **Engine:** MySQL family
- **Networking:**
  - VPC: Private VPC only
  - Subnets: Lambda & app subnets
  - Security Group: RDS Proxy-specific
- **Timeout Configuration:**
  - Idle Client Timeout: 1800 seconds (30 minutes)
  - Connection Borrow Timeout: 120 seconds
- **TLS:** Not required (internal network)
- **Authentication:** AWS Secrets Manager integration

**Connection Pool Configuration:**
```
Connection Pool Settings:
- Max Connections: 100% of Aurora cluster max
- Max Idle Connections: 50% of max
- Connection Recycle: 1 hour by default
```

#### 4. **RDS Proxy Target Group** (`aws_db_proxy_default_target_group`)
- **Purpose:** Routes connections from proxy to Aurora cluster
- **Connection Pool Settings:**
  - Max connections: 100%
  - Max idle connections: 50%
  - Connection borrow timeout: 120 seconds

#### 5. **RDS Proxy Target** (`aws_db_proxy_target`)
- **Links:** Proxy to Aurora cluster
- **Automatic:** Discovers all cluster instances
- **Load Balancing:** Distributes connections across cluster instances

#### 6. **Secrets Manager - Database Credentials** (`aws_secretsmanager_secret.aurora_db_secret`)
- **Name Template:** `{env}-aurora-db-secret-{random}`
- **Purpose:** Secure storage of Aurora credentials
- **Recovery Window:** Instant deletion (0 days)
- **Rotatable:** Yes (can be configured)
- **Tags:** Environment-specific

**Secret Contents:**
```json
{
  "username": "admin",
  "password": "auto-generated-16-char",
  "engine": "mysql",
  "host": "aurora-cluster-endpoint",
  "port": 3306,
  "dbClusterIdentifier": "dev-aurora-cluster"
}
```

#### 7. **Password Generation** (`random_password.aurora_db_password`)
- **Length:** 16 characters
- **Special Characters:** Enabled (!, #, $, %, ^, &, *, (, ), _, +, -, =)
- **Regeneration:** Only on first apply (persistent thereafter)

#### 8. **Elastic Container Registry (ECR) Repositories**

**Grafana Repository** (`aws_ecr_repository.grafana`)
- **Name:** `dev-grafana`
- **Purpose:** Stores Grafana monitoring UI Docker image
- **Tag Mutability:** Mutable (images can be overwritten)
- **Force Delete:** Enabled (for dev/test environments)

**Prometheus Repository** (`aws_ecr_repository.prometheus`)
- **Name:** `dev-prometheus`
- **Purpose:** Stores Prometheus metrics collection Docker image
- **Configuration:** Same as Grafana

**MySQL Exporter Repository** (`aws_ecr_repository.mysql_exporter`)
- **Name:** `dev-mysql-exporter`
- **Purpose:** Stores MySQL metrics exporter Docker image
- **Configuration:** Same as Grafana
- **Role:** Exports Aurora RDS metrics to Prometheus

**Loki Repository** (`aws_ecr_repository.loki`)
- **Name:** `dev-loki`
- **Purpose:** Stores Loki log aggregation service Docker image
- **Configuration:** Same as Grafana
- **Role:** Aggregates and stores logs from Alloy and other sources

**Alloy Repository** (`aws_ecr_repository.alloy`)
- **Name:** `dev-alloy`
- **Purpose:** Stores Grafana Alloy telemetry collection engine Docker image
- **Configuration:** Same as Grafana
- **Role:** Collects, enriches, and forwards logs to Loki

#### 9. **Docker Images** (source files in `modules/storage/`)

**Grafana Dockerfile** (`grafana/Dockerfile`)
- **Base Image:** Grafana official
- **Port:** 3000
- **Configuration:** Datasource integration with Prometheus

**Prometheus Dockerfile** (`prometheus/Dockerfile`)
- **Base Image:** Prometheus official
- **Port:** 9090
- **Configuration:** Scrapes metrics from MySQL Exporter and other targets
- **Config File:** `prometheus.yml` (defined below)

**Prometheus Configuration** (`prometheus/prometheus.yml`)
- **Global Settings:** Scrape interval, evaluation interval
- **Scrape Configs:**
  - MySQL Exporter targets (port 9104)
  - Prometheus self-monitoring (port 9090)
  - Any additional targets (CloudWatch, custom exporters)

**MySQL Exporter Dockerfile** (`matrix_exporter/Dockerfile`)
- **Base Image:** MySQL Exporter official
- **Port:** 9104
- **Purpose:** Exports Aurora RDS metrics (connections, queries, locks, etc.)
- **Configuration:** Connects via Secrets Manager credentials

**Loki Dockerfile** (`loki/Dockerfile`)
- **Base Image:** Loki official (grafana/loki:latest)
- **Port:** 3100
- **Purpose:** Log aggregation and storage service
- **Configuration:** Receives logs from Alloy via HTTP API
- **Data Storage:** In-memory or persistent storage for log retention

**Alloy Dockerfile** (`alloy/Dockerfile`)
- **Base Image:** Grafana Alloy official (grafana/alloy:latest)
- **Port:** 12345 (HTTP server for Alloy API)
- **Purpose:** Observability collector and log enrichment engine
- **Configuration:** Specified in `config.alloy` file
- **Features:**
  - Pulls logs from AWS CloudWatch
  - Enriches logs with GeoIP data from MaxMind database
  - Converts OpenTelemetry format to Loki format
  - Forwards enriched logs to Loki

#### 10. **Datasource Configuration** (`grafana/datasource.yml`)
```yaml
# Prometheus datasource for metrics
name: Prometheus
type: prometheus
url: http://prometheus:9090  # Internal DNS within ECS cluster

# Loki datasource for logs
name: Loki
type: loki
url: http://loki:3100  # Internal DNS within ECS cluster
```

#### 11. **Alloy Configuration** (`alloy/config.alloy`)

**Purpose:** Collect and enrich logs with geolocation data

**Data Flow:**
1. **CloudWatch Receiver**
   - Source: `/aws/vpn/dev-client-vpn` log group
   - Poll Interval: 1 minute
   - Extracts: VPN client connection logs with device IPs

2. **OTel to Loki Conversion**
   - Converts OpenTelemetry format to Loki format
   - Preserves log structure and metadata

3. **GeoIP Enrichment Stage**
   - Database: `GeoLite2-City.mmdb` (MaxMind)
   - Extracts device IP from log using regex
   - Translates IP to geographic coordinates (latitude/longitude)
   - Adds labels: `device_ip`, `geoip_latitude`, `geoip_longitude`

4. **Loki Export**
   - Endpoint: `http://localhost:3100/loki/api/v1/push`
   - Pushes enriched logs with geographic data
   - Enables geographic mapping of VPN connections in Grafana

**Key Features:**
- Automatic IP geolocation enrichment
- OpenTelemetry compliance
- Real-time log processing pipeline
- Cloud-native observability data collection
- VPN security and access tracking

#### 12. **MaxMind GeoIP Database**
- **File:** `alloy/GeoLite2-City.mmdb`
- **Purpose:** Geolocation database for IP-to-coordinate translation
- **License:** MaxMind Community License (free tier)
- **Coverage:** City-level geographic data for public IP addresses
- **Usage:** Enables mapping of VPN client connections and traffic sources to geographic locations in Grafana dashboards
- **Integration:** Loaded by Alloy during container startup

### Architecture Flow

**Data Flow - Metrics:**
```
Aurora MySQL Cluster
    ↓ (metrics export)
MySQL Exporter (port 9104)
    ↓ (pull metrics every 15s)
Prometheus (port 9090)
    ↓ (time-series data)
Grafana (port 3000)
    ↓ (HTTP/visualization)
Monitoring Dashboard (browser)
```

**Data Flow - Logs:**
```
AWS CloudWatch VPN Logs (/aws/vpn/dev-client-vpn)
    ↓ (poll every 1 minute)
Alloy (port 12345)
    ├─ Extract device IP
    ├─ Enrich with GeoIP data (GeoLite2-City.mmdb)
    └─ Convert to Loki format
    ↓
Loki (port 3100)
    ├─ Aggregate and index logs
    ├─ Store with geographic labels
    └─ Enable log queries
    ↓
Grafana (port 3000)
    ├─ Query logs from Loki
    ├─ Display with geographic mapping
    └─ Visualize VPN connection patterns
    ↓
Monitoring Dashboard (browser)
```

### Variables

**Database Configuration:**
- `subnet_group_name` - DB subnet group name for Aurora
- `private_vpc_id` - VPC ID for database resources
- `private_subnet_ids` - Subnet IDs for DB and Proxy (usually db_subnet1, db_subnet2)
- `private_vpc_cidr` - CIDR block for security group rules (10.2.0.0/16)

**Instance Configuration:**
- `aurora_instances` - Map of instance configurations (default: 1 x db.t3.medium)

**Common Variables:**
- `region` - AWS region (eu-central-1)
- `env` - Environment identifier (dev)
- `tags` - Resource tagging
- `email` - Notification email

### Security Considerations
- **Private Network Only:** Database is not accessible from internet
- **Secrets Manager Integration:** Credentials not stored in code or environment variables
- **Security Groups:** Restrict RDS Proxy access to Lambda and monitoring subnets
- **Encryption at Rest:** Can be enabled (currently disabled for dev)
- **Encryption in Transit:** RDS Proxy uses internal network (TLS not required)
- **IAM Authentication:** RDS Proxy uses Secrets Manager (not IAM tokens)

### Dependencies
- **Networking Module** - Requires private VPC, subnets, security groups
- **Certificates Module** - Optional for mutual TLS scenarios

### Output Exports
- Aurora cluster endpoint (connection string)
- RDS Proxy endpoint (application connection string)
- Aurora cluster ID
- DB subnet group name
- Security group IDs
- Secrets Manager secret ARN
- ECR repository URLs (Grafana, Prometheus, MySQL Exporter, Loki, Alloy)

### Performance Tuning
- **Connection Pooling:** RDS Proxy reduces database connection overhead
- **Multi-AZ:** Automatic failover provides high availability
- **Read Replicas:** Can be added for read-heavy workloads
- **Parameter Tuning:** Aurora MySQL parameters tunable via parameter groups

---

## Monitoring Module

### Purpose
The Monitoring module implements a comprehensive observability stack using ECS Fargate to run containerized Prometheus, Grafana, Loki, Alloy, and MySQL Exporter services. It provides metrics collection, log aggregation with GeoIP enrichment, visualization, budget tracking via AWS Budgets, and IAM roles for secure resource access.

### Components

#### 1. **ECS Cluster** (`aws_ecs_cluster.monitoring`)
- **Name:** `dev-monitoring-cluster`
- **Purpose:** Orchestrates containerized monitoring services
- **Launch Type:** Fargate (serverless container execution)
- **Networking:** Private VPC only
- **Tags:** Environment-specific (e.g., `dev-monitoring-cluster`)

#### 2. **CloudWatch Log Group** (`aws_cloudwatch_log_group.monitoring_logs`)
- **Name:** `/ecs/dev-monitoring`
- **Purpose:** Centralized logging for all monitoring containers
- **Retention:** 7 days
- **Log Streams:**
  - grafana - Grafana application logs
  - prometheus - Prometheus startup and reload logs
  - mysql-exporter - Exporter connection and metrics logs
- **Use:** Debugging, audit trail, performance analysis

#### 3. **ECS Task Definition** (`aws_ecs_task_definition.monitoring_stack`)
- **Family:** `dev-monitoring`
- **Network Mode:** awsvpc (uses Elastic Network Interface)
- **Launch Type Compatibility:** Fargate
- **Compute Resources:**
  - **CPU:** 1024 CPU units (1 vCPU)
  - **Memory:** 2048 MB (2 GB)
- **Task Execution Role:** IAM role for pulling ECR images, writing logs
- **Task Role:** IAM role for container application permissions

**Task Execution Role Permissions:**
```
- ecr:GetAuthorizationToken
- ecr:BatchGetImage
- ecr:GetDownloadUrlForLayer
- logs:CreateLogStream
- logs:PutLogEvents
```

**Task Role Permissions:**
- RDS database read access
- CloudWatch metrics write access
- Secrets Manager secret read access

#### 4. **Container Services**

**Container 1: Grafana**
```
Name: grafana
Image: {AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/{env}-grafana:latest
Port: 3000
Essential: Yes

Environment Variables:
- GF_ANALYTICS_CHECK_FOR_UPDATES: false (disable external checks)

Logging:
- Driver: CloudWatch
- Log Group: /ecs/dev-monitoring
- Stream Prefix: grafana
```

**Purpose:** Web UI for metrics visualization
- Connects to Prometheus as a data source
- Provides interactive dashboards
- Alerting rules integration
- User authentication (can be configured)

**Container 2: Prometheus**
```
Name: prometheus
Image: {AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/{env}-prometheus:latest
Port: 9090
Essential: Yes

Logging:
- Driver: CloudWatch
- Log Group: /ecs/dev-monitoring
- Stream Prefix: prometheus
```

**Purpose:** Time-series data collection and storage
- Scrapes metrics from exporters (MySQL Exporter)
- Stores metrics with 15-second resolution (configurable)
- Provides query language (PromQL) for metrics analysis
- Retention: 15 days by default (configurable)

**Container 3: Loki**
```
Name: loki
Image: {AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/{env}-loki:latest
Port: 3100
Essential: Yes

Logging:
- Driver: CloudWatch
- Log Group: /ecs/dev-monitoring
- Stream Prefix: loki
```

**Purpose:** Log aggregation and storage service
- Receives enriched logs from Alloy
- Indexes logs with labels (including geographic data)
- Provides LogQL query language for log analysis
- Enables efficient log searching and filtering
- Stores logs with retention policies (configurable)

**Container 4: Alloy**
```
Name: alloy
Image: {AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/{env}-alloy:latest
Port: 12345 (HTTP API)
Essential: Yes

Configuration File: /etc/alloy/config.alloy (mounted)
Database File: /etc/alloy/GeoLite2-City.mmdb (MaxMind)

Logging:
- Driver: CloudWatch
- Log Group: /ecs/dev-monitoring
- Stream Prefix: alloy
```

**Purpose:** Observability data collector and log enrichment
- Pulls logs from AWS CloudWatch (/aws/vpn/dev-client-vpn)
- Enriches logs with geolocation data using MaxMind database
- Converts OpenTelemetry format to Loki format
- Forwards enriched logs to Loki
- Enables geographic analysis of VPN connections and traffic

**Data Enhancement Pipeline:**
1. Extract CloudWatch logs from VPN endpoint
2. Parse device IP address from log entries
3. Look up geographic coordinates for IP (latitude/longitude)
4. Append as log labels
5. Forward to Loki for storage and querying

**Container 5: MySQL Exporter**
```
Name: mysqld-exporter
Image: {AWS_ACCOUNT_ID}.dkr.ecr.eu-central-1.amazonaws.com/{env}-mysql-exporter:latest
Port: 9104
Essential: True

Initialization:
- Entrypoint: shell script
- Command: Creates .my.cnf config file with DB credentials
  - User: ${DB_USER} (passed from var)
  - Password: ${DB_PASSWORD} (passed from var)
  - Host: ${DB_PROXY_ENDPOINT} (RDS Proxy endpoint)
  - Port: 3306
- Runs: mysqld_exporter with mysql config file

Logging:
- Driver: CloudWatch
- Log Group: /ecs/dev-monitoring
- Stream Prefix: mysql-exporter
```

**Purpose:** Exports Aurora RDS metrics
- Connects to RDS Proxy via credentials stored in env variables
- Metrics exported:
  - Connection count and status
  - Query statistics
  - Table lock wait times
  - Replication lag
  - InnoDB metrics
- Expose port 9104 for Prometheus scraping

#### 5. **IAM Roles for ECS**

**ECS Task Execution Role** (`aws_iam_role.ecs_execution_role`)
- **Trust Relationship:** ECS Tasks
- **Attached Policies:**
  - `AmazonECSTaskExecutionRolePolicy` (AWS managed)
  - Custom policy for CloudWatch Logs, ECR access

**ECS Task Role** (`aws_iam_role.ecs_task_role`)
- **Trust Relationship:** ECS Tasks
- **Custom Permissions:** (defined in monitoring_iam.tf)
  - CloudWatch Metrics `PutMetricData`
  - Secrets Manager `GetSecretValue`
  - RDS read access (optional, for ad-hoc queries)

#### 6. **AWS Budgets** (`aws_budgets_budget.monitoring_budget`)
- **Purpose:** Track and alert on AWS spending
- **Limit Amount:** $350 USD per month (configurable)
- **Scope:** Entire AWS account
- **Notifications:** Email alerts when threshold exceeded
- **Notifications Recipients:** `${var.email}` (547283@student.fontys.nl)
- **Threshold:**
  - Forecasted: Alert when forecast exceeds 80% of limit
  - Actual: Alert when actual usage exceeds 80% of limit

**Budget Alert Recipients:**
```
Primary Email: var.email
Type: Actual + Forecasted
Notification Trigger: 80% threshold
```

#### 7. **Networking Components** (related to monitoring)

**Monitoring Security Group** (`aws_security_group.monitoring_sg`)
- **Inbound Rules:**
  - Port 3000 from private VPC CIDR (Grafana UI)
  - Port 9090 from private VPC CIDR (Prometheus query/metrics)
  - Port 9104 from private VPC CIDR (MySQL Exporter metrics)
  - Port 3100 from private VPC CIDR (Loki logs API)
  - Port 12345 from private VPC CIDR (Alloy HTTP API)
- **Outbound Rules:**
  - All traffic to RDS Proxy (SQL queries for metrics)
  - All traffic to Secrets Manager (credential retrieval)
  - All traffic to CloudWatch (log collection by Alloy)
  - HTTPS outbound (for potential external integrations)

**RDS Proxy Security Group Modifications:**
- Inbound rule added for monitoring container security group
- Allows Prometheus/MySQL Exporter to connect and gather metrics

#### 8. **ECS Task Networking**
- **VPC:** Private VPC (10.2.0.0/16)
- **Subnets:** Private Lambda subnets (10.2.4.0/24, 10.2.5.0/24)
- **Network Interface:** Elastic Network Interface (ENI) with private IP
- **Security Group:** Monitoring-specific security group
- **DNS:** Private Route53 hosted zone

### Architecture Diagram

**Monitoring Stack Metrics Data Flow:**
```
Prometheus (port 9090)
    ↓ (scrapes every 15 seconds)
MySQL Exporter (port 9104)
    ↓
RDS Proxy (port 3306)
    ↓
Aurora MySQL Cluster
    ↓ (metrics exported)
Prometheus Database (TSDB)
    ↓ (query via HTTP)
Grafana (port 3000)
    ↓ (visualize metrics)
Dashboard (browser, port 3000)
```

**Monitoring Stack Logs Data Flow:**
```
AWS CloudWatch VPN Logs (/aws/vpn/dev-client-vpn)
    ↓ (poll every 1 minute)
Alloy (port 12345)
    ├─ Parse device IP
    ├─ Enrich with GeoIP (GeoLite2-City.mmdb)
    └─ Convert OTel → Loki format
    ↓
Loki (port 3100)
    ├─ Aggregate logs
    ├─ Index with geographic labels
    └─ Enable LogQL queries
    ↓
Grafana (port 3000)
    ├─ Query logs from Loki
    ├─ Display with geographic mapping
    └─ Visualize VPN connection patterns
    ↓
Dashboard (browser, port 3000)
```

**Integrated Observability:**
```
Grafana Dashboard (port 3000)
├─ Metrics Tab
│  └─ Query Prometheus (port 9090)
│     ├─ Database performance metrics
│     ├─ System resource utilization
│     └─ Application health
│
└─ Logs Tab
   └─ Query Loki (port 3100)
      ├─ VPN connection logs
      ├─ Geographic distribution of connections
      └─ Access patterns and anomalies
```

### Metrics Collected

**MySQL/Aurora Metrics:**
- Active connections
- Query throughput (queries per second)
- Slow query count
- Replication lag
- InnoDB buffer pool usage
- Table locks
- Bytes received/sent
- Uptime
- Version info

**System Metrics:**
- ECS task CPU utilization
- Task memory usage
- Network I/O
- Task creation/destruction

### Variables

**Monitoring Infrastructure:**
- `plg_ec2_instance_type` - Default: t3.micro (legacy, for reference)
- `vpn_sg_id` - Security group ID for VPN endpoint
- `private_vpc_id` - Private VPC ID (10.2.0.0/16)
- `private_vpc_cidr` - CIDR block for security group rules
- `private_subnet_ids` - Subnets for ECS task placement (lambda subnets)

**Database Integration:**
- `db_proxy_endpoint` - RDS Proxy connection string
- `db_username` - Aurora username (admin)
- `db_password` - Aurora password (from Secrets Manager)
- `rds_proxy_sg_id` - RDS Proxy security group ID

**Budget Configuration:**
- `limit_amount` - Monthly budget limit (default: $350)

**Common Variables:**
- `region` - AWS region (eu-central-1)
- `env` - Environment identifier (dev)
- `tags` - Resource tagging
- `email` - Budget alert notification email

### Deployment & CI/CD Integration

**GitHub Actions Deployment:**
The deploy_workflow.yml includes monitoring-specific steps:

```yaml
- name: Login to Amazon ECR
  if: matrix.module == 'monitoring'
  uses: aws-actions/amazon-ecr-login@v2

- name: Build and Push Monitoring Images
  if: matrix.module == 'monitoring'
  run: |
    docker build -t $ECR_REGISTRY/${env}-grafana:latest ./modules/storage/grafana/
    docker push $ECR_REGISTRY/${env}-grafana:latest
    
    docker build -t $ECR_REGISTRY/${env}-prometheus:latest ./modules/storage/prometheus/
    docker push $ECR_REGISTRY/${env}-prometheus:latest
    
    docker build -t $ECR_REGISTRY/${env}-mysql-exporter:latest ./modules/storage/matrix_exporter/
    docker push $ECR_REGISTRY/${env}-mysql-exporter:latest
    
    docker build -t $ECR_REGISTRY/${env}-loki:latest ./modules/storage/loki/
    docker push $ECR_REGISTRY/${env}-loki:latest
    
    docker build -t $ECR_REGISTRY/${env}-alloy:latest ./modules/storage/alloy/
    docker push $ECR_REGISTRY/${env}-alloy:latest
```

### Security Considerations
- **Private Network:** ECS task runs in private VPC subnets
- **No Direct Internet:** Monitoring stack cannot initiate outbound connections (except CloudWatch API)
- **Credentials Management:** DB credentials passed via environment variables (Secrets Manager integration)
- **IAM Roles:** Task roles restrict permissions to minimum required
- **Logging:** All container output logged to CloudWatch for audit trail
- **Task Role Isolation:** Separate execution and task roles for least privilege
- **VPN Log Encryption:** CloudWatch Logs from VPN endpoint are encrypted

### Limitations & Considerations
- **Single Task:** Currently runs as single Fargate task (no auto-scaling)
- **Metrics Storage:** Prometheus data persists in EBS-backed task storage (15-day retention, configurable)
- **Logs Storage:** Loki data persists in EBS-backed task storage (retention configurable)
- **Memory:** 2GB memory may be limiting for large datasets; can be increased
- **Scaling:** For production, consider ECS auto-scaling or clustering
- **No Alerts:** Prometheus rules configured but no SNS notifications (can be added)
- **GeoIP Updates:** MaxMind database not auto-updated; manual refresh needed

### Dependencies
- **Networking Module** - Requires private VPC, subnets, security groups
- **Storage Module** - Requires Aurora cluster, RDS Proxy, ECR repositories

### Output Exports
- ECS cluster name
- CloudWatch log group name
- Task definition ARN
- IAM role ARNs
- Security group IDs

---

## SOAR Module

### Purpose
The SOAR (Security Orchestration Automation Response) module implements automated security incident response capabilities. It detects malicious IP addresses and automatically blocks them via AWS WAF, enabling zero-trust defense mechanisms without manual intervention.

### Components

#### 1. **AWS Lambda Function - SOAR Responder** (`aws_lambda_function.soar_responder`)
- **Function Name:** `soar-responder`
- **Language:** Python 3.10
- **Source:** `modules/soar/lambda_src/soar.py`
- **Handler:** `soar_responder.lambda_handler`
- **Timeout:** 10 seconds
- **Memory:** 128 MB (default)
- **Package:** Zipped Python code via `archive_file`

**Environment Variables:**
```python
WAF_IP_SET_NAME = aws_wafv2_ip_set.waf_ip_blacklist.name
WAF_IP_SET_ID = aws_wafv2_ip_set.waf_ip_blacklist.id
WAF_SCOPE = "REGIONAL"
```

**Purpose:** Processes security alerts from SNS and updates WAF IP set
- Triggered by: SNS topic notifications
- Action: Adds malicious IPs to WAF blocklist
- Response Time: Sub-10-second automated response

#### 2. **SNS Integration** (`aws_sns_topic.sns`)
- **Name:** SOAR notification topic
- **Purpose:** Event-driven trigger for Lambda function
- **Message Flow:**
  1. Security alert generated (e.g., from AWS GuardDuty, custom detector)
  2. Alert published to SNS topic
  3. Lambda triggered automatically
  4. Lambda parses alert and extracts attacker IP
  5. Lambda updates WAF IP set

**SNS Subscription** (`aws_lambda_permission.allow_sns`)
```
Principal: SNS
Action: lambda:InvokeFunction
Source: SNS topic ARN
Effect: Allow SOAR Lambda to be invoked by SNS
```

#### 3. **AWS WAFv2 IP Set** (`aws_wafv2_ip_set.waf_ip_blacklist`)
- **Name:** Auto-generated (e.g., `dev-waf-ip-blacklist-xxxxx`)
- **Scope:** REGIONAL (restricts to specific AWS region)
- **IP Version:** IPV4
- **Initial State:** Empty (populated by SOAR Lambda)
- **Purpose:** Centralized IP blocklist for WAF rules

**IP Set Properties:**
```
Type: IPv4 addresses
Max Capacity: 10,000 IPs
Update Frequency: Real-time (via Lambda)
TTL: N/A (static until manually removed or Lambda updates)
```

#### 4. **AWS WAFv2 Web ACL** (`aws_wafv2_web_acl.waf`)
- **Name:** Auto-generated (e.g., `dev-waf`)
- **Scope:** REGIONAL
- **Description:** WAF rules for public ALB

**Default Action:** ALLOW (allow traffic by default)

**Rules:**

**Rule 1: SOAR Auto-Block Rule**
```
Name: soar-auto-block-rule
Priority: 1 (highest priority - evaluated first)
Action: BLOCK (deny matching traffic)
Condition: IP matches waf_ip_blacklist

Statement: ip_set_reference_statement
  - Checks if source IP in blacklist
  - Blocks request if matched

Metrics:
  - CloudWatch Metric: soar-blocked-ips
  - Sampled Requests: Captured for analysis

Flow:
  1. Request arrives at ALB
  2. WAF evaluates SOAR rule first
  3. If source IP in blacklist → BLOCK (408, 403 response)
  4. If IP not in blacklist → proceed to default action (ALLOW)
  5. Request forwarded to Lambda target
```

**Visibility Configuration:**
```
CloudWatch Metrics: Enabled
  - Metric Name: main-waf-metrics
  - Tracks: Allowed, blocked, and counted requests
  
Sampled Requests: Enabled
  - Logs sample of requests to CloudWatch
  - Used for debugging and threat analysis
```

#### 5. **IAM Role for SOAR Lambda** (`aws_iam_role.soar_lambda_role`)
- **Role Name:** `soar_lambda_execution_role`
- **Trust Relationship:** Lambda service
- **Attached Policies:** Inline policy for WAF updates

#### 6. **IAM Policy for WAF Access** (`aws_iam_role_policy.soar_waf_policy`)

**Actions Allowed:**
```
WAFv2 Permissions:
- wafv2:GetIPSet
- wafv2:UpdateIPSet

CloudWatch Logs Permissions:
- logs:CreateLogGroup
- logs:CreateLogStream
- logs:PutLogEvents

Resource Restrictions:
- WAF IP Set ARN (blocks access to specific IP set)
- CloudWatch logs: * (all logs - can be restricted)
```

**Policy Document:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "wafv2:GetIPSet",
        "wafv2:UpdateIPSet"
      ],
      "Resource": "arn:aws:wafv2:region:account:regional/ipset/id"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

#### 7. **Lambda Source Code** (`modules/soar/lambda_src/soar.py`)
- **Purpose:** Parse security alerts and update WAF
- **Dependencies:** boto3 (AWS SDK for Python)
- **Key Functions:**
  - Parse SNS message from alert system
  - Extract attacker IP address
  - Validate IP format (IPv4)
  - Call WAFv2 API to update IP set
  - Append IP to existing blocklist
  - Handle errors gracefully

**Pseudocode:**
```python
def lambda_handler(event, context):
    # 1. Parse SNS message
    message = json.loads(event['Records'][0]['Sns']['Message'])
    attacker_ip = message.get('attacker_ip')
    
    # 2. Validate IP
    if not is_valid_ipv4(attacker_ip):
        return error_response
    
    # 3. Get current IP set
    waf_client = boto3.client('wafv2')
    ip_set = waf_client.get_ip_set(
        Id=os.environ['WAF_IP_SET_ID'],
        Scope=os.environ['WAF_SCOPE'],
        Name=os.environ['WAF_IP_SET_NAME']
    )
    
    # 4. Append new IP
    current_ips = ip_set['IPSet']['Addresses']
    if attacker_ip not in current_ips:
        current_ips.append(attacker_ip)
    
    # 5. Update IP set
    waf_client.update_ip_set(
        Id=os.environ['WAF_IP_SET_ID'],
        Scope=os.environ['WAF_SCOPE'],
        Name=os.environ['WAF_IP_SET_NAME'],
        Addresses=current_ips,
        LockToken=ip_set['LockToken']
    )
    
    return success_response
```

### Architecture & Threat Response Flow

**Attack Scenario Example:**
```
1. Attacker (1.2.3.4) attempts DDoS on ALB
   ↓
2. GuardDuty detects malicious IP
   ↓
3. GuardDuty publishes finding to SNS
   ↓
4. SNS triggers SOAR Lambda
   ↓
5. Lambda extracts IP: 1.2.3.4
   ↓
6. Lambda calls WAF API
   ↓
7. WAF IP set updated: [1.2.3.4]
   ↓
8. Next request from 1.2.3.4
   ↓
9. WAF SOAR rule checks IP (priority 1)
   ↓
10. Match found → BLOCK request (403 Forbidden)
    ↓
11. Request never reaches ALB/Lambda
    ↓
12. Attack mitigated in <1 second
```

### Alert Sources (Potential Integrations)

1. **AWS GuardDuty**
   - Detects malicious IPs/domains
   - Publishes findings to EventBridge
   - Route to SNS for SOAR processing

2. **Custom IDS/IPS**
   - Internal security system detects intrusion
   - Publishes alert to SNS
   - SOAR Lambda processes alert

3. **AWS Security Hub**
   - Aggregates security findings
   - Route to SNS topic
   - SOAR processes high-severity findings

4. **Manual Incident Response**
   - Security team publishes IP to SNS
   - SOAR Lambda blocks immediately

### Metrics & Monitoring

**CloudWatch Metrics:**
- `soar-blocked-ips` - Count of requests blocked by SOAR rule
- `main-waf-metrics` - All WAF activity
- Log groups: `/aws/lambda/soar-responder` - Lambda execution logs

**CloudWatch Alarms (Can be added):**
- Alert if blocked IPs exceed threshold (DDoS indicator)
- Alert if Lambda execution failures (SOAR malfunction)
- Alert if WAF IP set near capacity (10,000 IP limit)

### Variables

**WAF Configuration:**
- None directly (hardcoded in WAF resource)

**Lambda Environment:**
- `WAF_IP_SET_NAME` - Blacklist name
- `WAF_IP_SET_ID` - Blacklist ID
- `WAF_SCOPE` - REGIONAL

**Common Variables:**
- `region` - AWS region (eu-central-1)
- `env` - Environment identifier (dev)
- `tags` - Resource tagging
- `email` - Alert recipient (stored in SNS)

### Security Considerations

**Strengths:**
- **Automated Response:** No manual intervention required
- **Real-time Blocking:** <1 second from alert to active block
- **No Database:** Simple architecture with minimal dependencies
- **Scalable:** Can handle thousands of simultaneous blocks
- **Audit Trail:** All updates logged to CloudWatch Logs

**Limitations & Considerations:**
- **IP Set Capacity:** Max 10,000 IPv4 addresses per IP set
- **IP Management:** No automatic expiration; IPs must be manually removed
- **False Positives:** Misconfigured alert sources could block legitimate traffic
- **Regional:** WAF rules only protect ALB in same region
- **No Geolocation:** Blocks by IP only; no geographic/contextual awareness
- **Maintenance:** Old IPs accumulate; need cleanup process

### Deployment & CI/CD

**GitHub Actions:**
```yaml
- name: Terraform Plan
  run: terraform plan -out=tfplan -var-file global/variables.tfvars
  
- name: Terraform Apply
  run: terraform apply -auto-approve tfplan
```

### IP Set Management Best Practices

1. **Monitoring:** Alert when IP set near 90% capacity
2. **Cleanup Process:** Scheduled Lambda to remove IPs after 30 days
3. **Whitelisting:** Separate IP set for trusted sources (optional)
4. **Rate Limiting:** WAF rule to limit requests per IP (optional)
5. **Logging:** Enable CloudTrail for WAF API calls
6. **Backup:** Automated export of IP set to S3 daily

### Dependencies
- **Networking Module** - Requires ALB and public VPC
- **Compute Module** - ALB must exist before WAF association

### Output Exports
- Lambda function ARN
- SNS topic ARN
- WAF ACL ARN
- IP set ARN
- CloudWatch log group name

---

## Compute Module

### Purpose
The Compute module provisions the web application infrastructure using AWS Lambda for serverless compute and Application Load Balancer (ALB) for ingress traffic management. It creates a cost-effective, scalable web application that connects to Aurora MySQL via RDS Proxy, with traffic protected by WAF rules defined in the SOAR module.

### Components

#### 1. **Application Load Balancer (ALB)** (`aws_lb.alb`)
- **Name:** `dev-alb`
- **Type:** Application Load Balancer
- **Scheme:** Internet-facing (receives traffic from internet)
- **VPC:** Public VPC (10.1.0.0/16)
- **Subnets:** Public ALB subnets (10.1.1.0/24, 10.1.2.0/24)
- **Security Group:** ALB-specific security group (multiple AZs)
- **Tags:** Environment-specific naming (e.g., `dev-alb`)

**Access Logging:**
```
Bucket: Terraform-managed S3 bucket for ALB logs
Enabled: True
Prefix: Optional (can organize by date/path)
Retention: Policy managed by lifecycle rules
Purpose: Audit trail, compliance, debugging
```

**Health:**
- Multi-AZ deployment across 2 availability zones
- Automatic failover between AZs
- Health checks on target group

#### 2. **ALB Target Group** (`aws_lb_target_group.lambda_tg`)
- **Name:** `dev-lambda-tg`
- **Target Type:** Lambda (not EC2 or IP)
- **Port:** N/A (Lambda invocation, not network port)
- **Purpose:** Routes ALB requests to Lambda function
- **Health Check:** None (Lambda invocations don't have HTTP health checks)

**Stickiness:** Not applicable to Lambda targets

#### 3. **ALB Listener** (`aws_lb_listener.alb_listener`)
- **Port:** 443 (HTTPS)
- **Protocol:** HTTPS
- **SSL Policy:** ELBSecurityPolicy-2016-08 (supports TLS 1.2, strong ciphers)
- **Certificate:** Server certificate from Certificates module
- **Default Action:** Forward to Lambda target group

**SSL Configuration:**
```
Protocol: TLS 1.2 required
Ciphers: Strong algorithms (no RC4, DES)
Cipher Format: Standard ELB cipher suite
Perfect Forward Secrecy: Enabled
```

**Request Flow:**
```
Client HTTPS Request (443)
    ↓
ALB Terminates TLS
    ↓
Reads SNI (Server Name Indication)
    ↓
Validates certificate (${alb_cert_arn})
    ↓
Decrypts request body
    ↓
Applies WAF rules (SOAR block check)
    ↓
Forwards to Lambda target group
    ↓
Lambda processes request
    ↓
Response sent back over TLS
    ↓
Client receives HTTPS response (443)
```

#### 4. **ALB to Lambda Target Attachment** (`aws_lb_target_group_attachment.lambda_attachment`)
- **Relationship:** Links target group to Lambda function
- **Lambda ARN:** `${aws_lambda_function.web_app.arn}`
- **Dependencies:** Requires ALB permission (`aws_lambda_permission.allow_alb`)

#### 5. **Lambda Permission** (`aws_lambda_permission.allow_alb`)
- **Function:** `${aws_lambda_function.web_app.function_name}`
- **Action:** `lambda:InvokeFunction`
- **Principal:** `elasticloadbalancing.amazonaws.com` (ALB service)
- **Source ARN:** Lambda target group ARN
- **Effect:** Allow ALB to invoke Lambda

**Security Aspect:** Only the specific ALB can invoke this Lambda (not public internet directly)

#### 6. **Lambda Function - Web App** (`aws_lambda_function.web_app`)
- **Function Name:** `dev-web-app`
- **Language:** Node.js 18.x
- **Handler:** `index.handler`
- **Runtime:** nodejs18.x
- **Execution Role:** IAM role with database access
- **Source:** Zipped code from `modules/compute/lambda_src/`

**Lambda Configuration:**
```
Memory: 128 MB (default, can be increased)
Timeout: 3 seconds (default, should match DB query time)
Ephemeral Storage: 512 MB (default)
Architecture: x86_64
Layers: None
Code Signing: N/A
```

**VPC Configuration:**
```
VPC: Private VPC (10.2.0.0/16)
Subnets: Lambda subnets (10.2.4.0/24, 10.2.5.0/24)
  - Ensures Lambda can reach RDS Proxy
  - No internet access (NAT gateway required for external API calls)
Security Group: Lambda-specific security group
  - Allows outbound to RDS Proxy (port 3306)
  - Allows outbound to Secrets Manager via VPC endpoint
```

**Environment Variables:**
```
DB_HOST = ${aurora_proxy_endpoint}     # RDS Proxy endpoint
DB_USER = ${aurora_username}           # Database username (admin)
DB_PASSWORD = ${aurora_password}       # Database password (15-char random)
```

**Execution:**
```
Cold Start: ~1-2 seconds (first invocation)
Warm Start: ~100-200ms (subsequent invocations)
Throughput: 1,000+ concurrent executions (default limit)
Scaling: Auto (no configuration needed)
```

#### 7. **Lambda IAM Execution Role** (`aws_iam_role.lambda_exec_role`)

**Trust Policy:** Lambda service

**Permissions:**
```
logs:CreateLogGroup
logs:CreateLogStream
logs:PutLogEvents
  → Write function logs to CloudWatch

ec2:CreateNetworkInterface
ec2:DescribeNetworkInterfaces
ec2:DeleteNetworkInterface
  → Manage ENI in private VPC
  
secretsmanager:GetSecretValue
  → Retrieve database credentials (if used)
  
s3:GetObject
  → Read Lambda source code (if from S3)
```

#### 8. **Lambda Source Code Generation** (`local_file.lambda_template`)
- **Path:** `modules/compute/lambda_src/index.mjs` (ES6 module syntax)
- **Runtime:** Node.js 18.x (supports ES6 modules)
- **Handler:** Exports `handler` function

**Lambda Code: Database Connection Test**

```javascript
import mysql from 'mysql2/promise';

export const handler = async (event) => {
  const dbHost = process.env.DB_HOST;
  const dbUser = process.env.DB_USER;
  const dbPassword = process.env.DB_PASSWORD;

  try {
    // 1. Create MySQL connection via RDS Proxy
    const connection = await mysql.createConnection({
      host: dbHost,
      user: dbUser,
      password: dbPassword,
      connectTimeout: 3000 // 3 seconds
    });

    // 2. Execute test query
    const [rows] = await connection.execute('SELECT 1 + 1 AS solution');
    await connection.end();

    // 3. Return success response
    return {
      statusCode: 200,
      headers: { "Content-Type": "text/html" },
      body: `
        <div style="font-family: sans-serif; padding: 20px;">
          <h1 style="color: #4CAF50;">✅ Full Database Connection Successful!</h1>
          <p>RDS Proxy: <b>${dbHost}</b></p>
          <p>Query Result: <b>${rows[0].solution}</b></p>
        </div>
      `
    };

  } catch (err) {
    // 4. Return error response
    return {
      statusCode: 500,
      headers: { "Content-Type": "text/html" },
      body: `
        <div style="font-family: sans-serif; padding: 20px;">
          <h1 style="color: #F44336;">❌ Connection Failed!</h1>
          <p>Error: ${err.message}</p>
        </div>
      `
    };
  }
};
```

**ALB Integration:**
- ALB sends HTTP request to Lambda
- Lambda returns HTTP response (status code, headers, body)
- ALB applies response transformations (CORS, redirects, etc.)
- Response sent back to client

#### 9. **Lambda Code Packaging** (`data.archive_file.lambda_zip`)
- **Source:** `modules/compute/lambda_src/` directory
- **Output:** `soar.zip` in module directory
- **Format:** ZIP archive
- **Triggers:** Automatic rebuild on source code changes

#### 10. **Lambda Security Group** (`aws_security_group.lambda_sg`)

**Inbound Rules:**
- None (Lambda not directly accessible)
- ALB does not establish network connection to Lambda
- Lambda invocation happens via AWS internal APIs

**Outbound Rules:**
```
Destination: RDS Proxy security group
Port: 3306/TCP (MySQL)
Protocol: TCP
Purpose: Allow Lambda to connect to database

Destination: 443/TCP
Protocol: TCP
Purpose: HTTPS for Secrets Manager, CloudWatch, etc.

Others: Typically restricted in production
```

#### 11. **ALB Security Group** (`aws_security_group.alb_sg`)

**Inbound Rules:**
```
Protocol: HTTPS (443)
Source: 0.0.0.0/0 (anywhere on internet)
Purpose: Accept user connections

Protocol: HTTP (80)
Source: 0.0.0.0/0 (anywhere on internet)
Purpose: Redirect to HTTPS (optional)
```

**Outbound Rules:**
- No outbound required (ALB invokes Lambda via AWS APIs)

#### 12. **WAF Association** (`aws_wafv2_web_acl_association.alb_waf_link`)
- **Resource ARN:** `${aws_lb.alb.arn}`
- **Web ACL ARN:** WAF from SOAR module
- **Effect:** Applies SOAR IP blocking rules to all ALB traffic
- **Precedence:** WAF evaluated before Lambda invocation

**Request Evaluation Order:**
```
1. ALB receives request (443/HTTPS)
2. WAF evaluates rules:
   a. SOAR auto-block rule (priority 1)
      - If source IP in blacklist → BLOCK (403)
   b. Other rules (if configured)
3. If allowed by WAF:
   a. ALB forwards to Lambda target group
4. Lambda processes:
   a. Database query
   b. Response generation
5. Response sent back to ALB
6. ALB sends to client
```

### Application Architecture Flow

**Request Lifecycle:**
```
1. User Request (HTTPS, port 443)
   │
   ├─ User enters: https://example.com
   │
   ├─ Request reaches ALB (Internet-facing)
   │
   ├─ ALB terminates TLS (decrypts request)
   │
   ├─ WAF evaluates SOAR rules
   │   │
   │   ├─ SOAR rule check: Is source IP in blacklist?
   │   │   ├─ Yes → BLOCK request (403 Forbidden)
   │   │   └─ No → Continue
   │   │
   │   └─ Other rules (if configured)
   │
   ├─ ALB forwards to Lambda target group
   │
   ├─ Lambda invoked (synchronous invocation)
   │
   ├─ Lambda establishes MySQL connection
   │   │
   │   ├─ Connects to RDS Proxy endpoint
   │   │
   │   ├─ Uses credentials from environment
   │   │
   │   └─ Connection pooled by RDS Proxy
   │
   ├─ Lambda executes SQL query
   │   │
   │   └─ Query: SELECT 1 + 1 AS solution
   │
   ├─ Aurora returns result (solution = 2)
   │
   ├─ Lambda closes database connection
   │
   ├─ Lambda returns HTTP response (200 OK)
   │   │
   │   └─ Body: HTML with success message
   │
   ├─ ALB encapsulates response in TLS
   │
   ├─ Response sent back to user
   │
   └─ User sees: "Full Database Connection Successful!"
```

**Response Content (HTML):**
```html
<div style="font-family: sans-serif; padding: 20px;">
  <h1 style="color: #4CAF50;">✅ Full Database Connection Successful!</h1>
  <p>The Lambda function reached the RDS Proxy at <b>dev-rds-proxy.xxxxx.rds.amazonaws.com</b>.</p>
  <p>Authentication was successful.</p>
  <p><b>Database Query Result (SELECT 1 + 1):</b> <b>2</b></p>
</div>
```

### Deployment & Scaling

**Deployment Process:**
1. Lambda code updated in Git
2. GitHub Actions triggered
3. Code zipped and uploaded to Lambda
4. Lambda function updated (no downtime)
5. Rollback possible via versioning

**Auto-Scaling:**
```
Concurrency: 1,000 simultaneous Lambda invocations (default)
Scaling: Automatic (no configuration needed)
Burst Capacity: Can scale up quickly within account limits
Connection Pooling: RDS Proxy handles connection limits
```

**Example Scaling Scenario:**
```
0 requests/sec → 0 Lambda invoications
100 requests/sec → 100 concurrent Lambdas (1 each)
1,000 requests/sec → 1,000 concurrent Lambdas
10,000 requests/sec → 1,000 Lambdas + queued requests
```

### Monitoring & Logging

**CloudWatch Logs:**
```
Log Group: /aws/lambda/dev-web-app
Log Streams: One per Lambda invocation (auto-created)
Retention: 1 day (default, configurable)
Metrics: Duration, errors, throttles, concurrent executions
```

**Cloudwatch Metrics:**
```
Invocations: Total number of Lambda invocations
Duration: Time to execute handler
Errors: Failed invocations (exceptions)
Throttles: Rejected invocations (quota exceeded)
ConcurrentExecutions: Currently running Lambdas
UnreservedConcurrentExecutions: Available capacity
```

**Example CloudWatch Query:**
```
fields @timestamp, @duration, @maxMemoryUsed, @memorySize
| stats avg(@duration), max(@maxMemoryUsed) by bin(@timestamp, 5m)
```

### Variables

**Networking:**
- `private_vpc_id` - Private VPC ID (10.2.0.0/16)
- `public_vpc_id` - Public VPC ID (10.1.0.0/16)
- `public_alb_subnet_ids` - ALB subnet IDs (public subnets)
- `private_lambda_subnet_ids` - Lambda subnet IDs (private subnets)

**Database Configuration:**
- `aurora_proxy_endpoint` - RDS Proxy connection string (DNS name)
- `aurora_username` - Database user (admin)
- `aurora_password` - Database password (random, 16-char)
- `rds_proxy_sg_id` - RDS Proxy security group ID

**Security:**
- `alb_cert_arn` - Server certificate ARN from Certificates module
- `alb_logs_bucket_arn` - S3 bucket for ALB access logs
- `waf_arn` - WAF Web ACL ARN from SOAR module

**Common Variables:**
- `region` - AWS region (eu-central-1)
- `env` - Environment identifier (dev)
- `tags` - Resource tagging
- `email` - Alert recipient

### Security Considerations

**Strengths:**
- **Private Compute:** Lambda runs in private VPC (no internet exposure)
- **Application Load Balancing:** Distributes traffic across availability zones
- **WAF Protection:** SOAR rules block malicious IPs at ALB layer
- **Encryption:** All traffic encrypted in transit (TLS)
- **IAM Roles:** Lambda has least-privilege permissions
- **No SSH/RDP:** Serverless (no shell access needed)

**Potential Improvements:**
- **DDoS Protection:** Enable AWS Shield Advanced
- **Rate Limiting:** Add WAF rule for per-IP rate limiting
- **Request Logging:** Log all requests to S3 for analysis
- **API Throttling:** Implement application-level throttling
- **Request Validation:** Add WAF rules for input validation (SQL injection, XSS)
- **CORS Headers:** Configure for specific origins

### Dependencies
- **Networking Module** - Requires public/private VPCs, subnets, security groups
- **Storage Module** - Requires Aurora cluster, RDS Proxy, Secrets Manager
- **Certificates Module** - Requires ALB certificate
- **SOAR Module** - Requires WAF Web ACL ARN

### Output Exports
- ALB DNS name
- ALB ARN
- Lambda function ARN
- Target group ARN
- Security group IDs
- IAM role ARNs

---

## Service Dependencies Summary

```
                    Certificates
                         ↓
                     (ALB cert)
                         ↓
    ┌────────────────────┼────────────────────┐
    ↓                    ↓                    ↓
Networking           Storage             SOAR
    ↓                    ↓                    ↓
(VPCs, subnets,    (Aurora RDS, →    (WAF Rules)
 TGW, SGs)          ECR repos)              ↓
    ↓                    ↓                    ↓
    └────────────────────┼────────────────────┘
                         ↓
                    Monitoring (ECS)
                    (monitors Storage)
                         ↓
                      Compute (ALB + Lambda)
```

**Deployment Order:**
1. `security` - IAM roles/policies
2. `certificates` - SSL certificates
3. `networking` - VPCs, subnets, Transit Gateway
4. `storage` - Aurora, RDS Proxy, ECR, Secrets Manager
5. `monitoring` - ECS cluster, containers
6. `soar` - Lambda, WAF, SNS
7. `compute` - ALB, Lambda web app

**Parallel Deployable:**
- `security` and `certificates` (can deploy simultaneously)
- All modules require `networking` to be deployed first

---

## Deployment Instructions

### Prerequisites
- AWS Account with appropriate permissions
- Terraform installed (v1.0+)
- AWS CLI configured
- GitHub repository with Actions enabled
- Global OIDC role provisioned (via `global/` bootstrap)

### Deploy via GitHub Actions
```bash
# 1. Commit changes to main branch
git add .
git commit -m "Update infrastructure"
git push origin main

# 2. GitHub Actions automatically:
#    - Initializes Terraform backend (S3 + DynamoDB lock)
#    - Runs terraform plan
#    - Applies each module in order (security→cert→net→storage→mon→soar→compute)
```

### Deploy Locally
```bash
cd env/dev/certificates
terraform init
terraform plan -var-file=../../global/variables.tfvars
terraform apply -var-file=../../global/variables.tfvars

# Repeat for each module in order
```

---

## Conclusion

This comprehensive infrastructure represents an enterprise-grade, serverless architecture with:
- **High Security:** Multi-VPC, air-gapped databases, WAF protection
- **Scalability:** Auto-scaling Lambda, connection pooling via RDS Proxy
- **Observability:** Prometheus + Grafana monitoring stack
- **Automation:** SOAR-based incident response
- **Infrastructure as Code:** Terraform modules with CI/CD pipeline

Each module can be independently updated and redeployed without affecting others, enabling rapid iteration and safe changes in a production environment.
