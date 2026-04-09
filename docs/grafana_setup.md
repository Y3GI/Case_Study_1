# �️ Grafana SOC Dashboard & SOAR Setup Guide

This document outlines the manual UI configuration required in Grafana after the Terraform infrastructure and PLG (Prometheus, Loki, Grafana) stack have been successfully deployed.
## Table of Contents

1. [Configure the SNS Contact Point](#1-configure-the-sns-contact-point)
2. [Notification Policies](#2-notification-policies)
3. [Create the WAF SOAR Alert Rule](#3-create-the-waf-soar-alert-rule)
4. [Build the SOC Dashboard](#4-build-the-soc-dashboard)
   - [4.1 Network & Access Monitoring](#41-network--access-monitoring)
   - [4.2 Database Performance & Health](#42-database-performance--health)
   - [4.3 Serverless (Lambda) Monitoring](#43-serverless-lambda-monitoring)
   - [4.4 Centralized Log Analytics](#44-centralized-log-analytics)

---
## 1. Configure the SNS Contact Point

To allow Grafana to trigger the AWS Lambda SOAR response, we must connect it to our AWS SNS Topic.

1. Navigate to **Alerting** > **Contact points** in the Grafana left menu.
2. Click **+ Add contact point**.
3. **Name:** `AWS SOAR SNS`
4. **Integration Type:** Select `Amazon SNS`.
5. **Topic:** Enter the full ARN of your SNS Topic.
6. **Auth Provider:** Select `Workspace IAM Role`.
7. Click **Test**, then **Save contact point**.

## 2. Notification Policies

1. Navigate to **Alerting** > **Notification policies**.
2. Edit the **Default policy**.
3. Change the **Contact point** to your newly created `AWS SOAR SNS`.
4. Save the policy.

## 3. Create the WAF SOAR Alert Rule

This rule monitors CloudWatch for brute-force attacks and fires the payload to SNS.

1. Navigate to **Alerting** > **Alert rules** > **+ New alert rule**.

### Step 1: Select the CloudWatch data source

- Query Type: `CloudWatch Logs Insights`
- Select your ALB Access Logs group
- Query to use:

```text
filter ispresent(httpRequest.clientIp) | stats count(*) as RequestCount by bin(1m), httpRequest.clientIp
```

- **Condition:** Set the threshold to evaluate if the `RequestCount` is **Above 50**.

### Step 2: Alert evaluation behavior

- **Folder:** `Security Alerts`
- **Evaluation group:** `1-minute`
- Configure no data: Set "Alert state if no data or all values are null" to **OK**.

### Step 3: Alert details

- **Rule name:** `WAF_Brute_Force_Detection`
- Save and exit.

## 4. Build the SOC Dashboard

Navigate to **Dashboards** > **+ New dashboard**. Add the following panels.

### 4.1 Network & Access Monitoring

#### AWS Client VPN GeoMap

- **Visualization:** `Geomap`
- **Data Source:** `Loki`
- **Transformations:** Add "Labels to fields" AND "Convert field type" (Set `geoip_latitude` and `geoip_longitude` to Number)
- **Geomap Settings:**
  - Location mode: `Coords`
  - Latitude: `geoip_latitude`
  - Longitude: `geoip_longitude`
- **Loki Query:**
```logql
sum by (device_ip, geoip_latitude, geoip_longitude) (count_over_time({exporter="OTLP"} [6h]))
```

### 4.2 Database Performance & Health

#### Aurora RDS CPU Utilization

- **Visualization:** `Gauge`
- **Data Source:** `CloudWatch`
- **Query Type:** `CloudWatch Metrics`
- **Namespace:** `AWS/RDS`
- **Metric Name:** `CPUUtilization`
- **Dimensions:** `DBInstanceIdentifier` = your-db-identifier
- **Statistic:** `Average`

#### Active Database Connections

- **Visualization:** `Stat` or `Time series`
- **Data Source:** `Prometheus`
- **Prometheus Query:**
```promql
mysql_global_status_threads_connected
```

#### Slow Queries Rate

- **Visualization:** `Time series`
- **Data Source:** `Prometheus`
- **Prometheus Query:**
```promql
rate(mysql_global_status_slow_queries[5m])
```

### 4.3 Serverless (Lambda) Monitoring

#### SOAR Lambda Invocations & Errors

- **Visualization:** `Time series`
- **Data Source:** `CloudWatch`
- **Query Type:** `CloudWatch Metrics`
- **Namespace:** `AWS/Lambda`
- **Metric Name:** Select both `Invocations` and `Errors`
- **Dimensions:** `FunctionName` = `soar-execution-lambda`
- **Statistic:** `Sum`

#### SOAR Lambda Execution Duration

- **Visualization:** `Time series`
- **Data Source:** `CloudWatch`
- **Query Type:** `CloudWatch Metrics`
- **Namespace:** `AWS/Lambda`
- **Metric Name:** `Duration`
- **Dimensions:** `FunctionName` = `soar-execution-lambda`
- **Statistic:** `Average`

### 4.4 Centralized Log Analytics

#### Critical Application Errors

- **Visualization:** `Logs`
- **Data Source:** `Loki`
- **Loki Query:**
```logql
{exporter="OTLP"} |~ "(?i)(error|panic|fatal|exception)"
```

#### Log Ingestion Volume by Container

- **Visualization:** `Time series` (Stacked area chart)
- **Data Source:** `Loki`
- **Loki Query:**
```logql
sum by (container) (rate({exporter="OTLP"}[5m]))
```