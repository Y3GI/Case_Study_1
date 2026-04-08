# 📊 Grafana SOC Dashboard & SOAR Setup Guide

This document outlines the manual UI configuration required in Grafana after the Terraform infrastructure and PLG (Prometheus, Loki, Grafana) stack have been successfully deployed.

## 1. Configure the SNS Contact Point
To allow Grafana to trigger the AWS Lambda SOAR response, we must connect it to our AWS SNS Topic.

1. Navigate to **Alerting** -> **Contact points** in the Grafana left menu.
2. Click **+ Add contact point**.
3. **Name:** `AWS SOAR SNS`
4. **Integration Type:** Select `Amazon SNS`.
5. **Topic:** Enter the full ARN of your SNS Topic (e.g., `arn:aws:sns:eu-central-1:123456789012:soar-alerts`).
6. **Auth Provider:** Select `Workspace IAM Role` (Grafana will automatically use the Fargate Task Role permissions).
7. Click **Test** to verify permissions, then **Save contact point**.

## 2. Notification Policies
1. Navigate to **Alerting** -> **Notification policies**.
2. Edit the **Default policy** (or create a specific route for Security Alerts).
3. Change the **Contact point** to your newly created `AWS SOAR SNS`.
4. Save the policy.

## 3. Create the WAF SOAR Alert Rule
This rule monitors CloudWatch for brute-force attacks and fires the payload to SNS.

1. Navigate to **Alerting** -> **Alert rules** -> **+ New alert rule**.
2. **Step 1: Define query and condition**
   * Select the **CloudWatch** data source.
   * Query Type: `CloudWatch Logs Insights`.
   * Select your ALB Access Logs group.
   * Enter the following query to extract IPs and bin them by time:
     ```text
     filter ispresent(httpRequest.clientIp)
     | stats count(*) as RequestCount by bin(1m), httpRequest.clientIp
     ```
   * **Condition:** Set the threshold to evaluate if the `RequestCount` is **Above 50**.
3. **Step 2: Alert evaluation behavior**
   * **Folder:** `Security Alerts`
   * **Evaluation group:** Create a `1-minute` group.
   * **Pending period:** `0s` (Fire immediately upon threshold breach).
   * **Configure no data and error handling:**
     * Alert state if no data or all values are null: **OK** (Crucial: prevents false positives when there is no traffic).
     * Alert state if execution error or timeout: **Alerting**.
4. **Step 3: Add details**
   * **Rule name:** `WAF_Brute_Force_Detection`
   * **Summary:** `Brute Force Attack Detected!`
5. **Save and exit.**

## 4. Build the SOC Dashboard
Navigate to **Dashboards** -> **+ New dashboard**. Add the following panels to monitor your stack:

### Panel 1: AWS Client VPN GeoMap (Loki)
* **Visualization:** `Geomap`
* **Data Source:** `Loki`
* **Query:** ```logql
  {awslogs_stream_prefix="promtail"} |= "connection-attempt" |= "successful"
  * **Geomap Settings:**
  * Location mode: `Coords`
  * Latitude field: `geoip_latitude`
  * Longitude field: `geoip_longitude`
* *Note: Requires the custom Promtail container with the MaxMind GeoLite2 City database.*

### Panel 2: SOAR Lambda Executions (CloudWatch)
* **Visualization:** `Time series`
* **Data Source:** `CloudWatch`
* **Query Type:** `CloudWatch Metrics`
* **Namespace:** `AWS/Lambda`
* **Metric Name:** `Invocations` & `Errors`
* **Dimensions:** `FunctionName` = `soar-execution-lambda`
* **Statistic:** `Sum`

### Panel 3: Aurora RDS CPU Utilization (CloudWatch)
* **Visualization:** `Gauge`
* **Data Source:** `CloudWatch`
* **Query Type:** `CloudWatch Metrics`
* **Namespace:** `AWS/RDS`
* **Metric Name:** `CPUUtilization`
* **Dimensions:** `DBInstanceIdentifier` = `<your-db-identifier>`
* **Statistic:** `Average`

### Panel 4: Active Database Connections (Prometheus)
* **Visualization:** `Stat` or `Time series`
* **Data Source:** `Prometheus`
* **Query:** ```promql
  mysql_global_status_threads_connected
* *Note: Requires the mysqld-exporter container running and connected to the Aurora Proxy.*