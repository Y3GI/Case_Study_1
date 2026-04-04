import json
import boto3
import os
import logging

# Set up logging so we can monitor the SOAR system itself in CloudWatch (Requirement P2-08)
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialize the AWS WAFv2 client
waf_client = boto3.client('wafv2')

def lambda_handler(event, context):
    logger.info("SOAR Lambda Triggered by SNS Event.")
    
    try:
        # 1. Extract the SNS message from the event wrapper
        sns_message = event['Records'][0]['Sns']['Message']
        
        # 2. Parse the Grafana Webhook JSON payload
        grafana_alert = json.loads(sns_message)
        logger.info(f"Received Alert: {grafana_alert.get('title', 'Unknown Alert')}")
        
        # 3. Check if this is a "firing" alert (not a "resolved" notification)
        if grafana_alert.get('state') != 'alerting':
            logger.info("Alert is not in 'alerting' state. No action required.")
            return {'statusCode': 200, 'body': 'Ignored non-firing alert.'}
        
        # 4. Extract the malicious IP address from the Grafana tags/labels
        # (Assuming your Grafana alert passes the offending IP in a label called 'attacker_ip')
        alerts = grafana_alert.get('alerts', [])
        for alert in alerts:
            attacker_ip = alert.get('labels', {}).get('attacker_ip')
            
            if attacker_ip:
                logger.warning(f"Malicious IP detected: {attacker_ip}. Initiating automated response.")
                block_ip_in_waf(attacker_ip)
            else:
                logger.info("No 'attacker_ip' label found in the alert payload.")
                
        return {
            'statusCode': 200,
            'body': json.dumps('SOAR Automated Response Completed Successfully.')
        }

    except Exception as e:
        logger.error(f"SOAR Automation Failed: {str(e)}")
        # We raise the exception so AWS Lambda marks this execution as a failure, 
        # which you can then visualize on your SOAR Grafana dashboard!
        raise e

def block_ip_in_waf(ip_address):
    """
    Helper function to add an IP address to an existing AWS WAFv2 IP Set.
    """
    # These environment variables will be passed in via Terraform
    ip_set_name = os.environ['WAF_IP_SET_NAME']
    ip_set_id = os.environ['WAF_IP_SET_ID']
    scope = os.environ.get('WAF_SCOPE', 'REGIONAL') # 'REGIONAL' for ALB, 'CLOUDFRONT' for Edge
    
    try:
        # First, we must get the current IP set and its lock token
        response = waf_client.get_ip_set(
            Name=ip_set_name,
            Scope=scope,
            Id=ip_set_id
        )
        
        lock_token = response['LockToken']
        current_addresses = response['IPSet']['Addresses']
        
        # Format the IP for WAF (must be CIDR notation, e.g., 192.168.1.50/32)
        cidr_ip = f"{ip_address}/32"
        
        if cidr_ip in current_addresses:
            logger.info(f"IP {cidr_ip} is already in the WAF Blocklist.")
            return
            
        # Append the new malicious IP to the existing list
        current_addresses.append(cidr_ip)
        
        # Update the WAF IP Set
        waf_client.update_ip_set(
            Name=ip_set_name,
            Scope=scope,
            Id=ip_set_id,
            Addresses=current_addresses,
            LockToken=lock_token
        )
        logger.info(f"SUCCESS: IP {cidr_ip} has been added to the WAF Blocklist.")
        
    except Exception as e:
        logger.error(f"Failed to update WAF IP Set: {str(e)}")
        raise e