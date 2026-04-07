import re
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
        # 1. Grab the raw text message from SNS
        sns_message = event['Records'][0]['Sns']['Message']
        logger.info(f"Received raw alert:\n{sns_message}")

        # 2. Search the text for our specific label using Regex
        # This looks for "attacker_ip = " followed by an IP address
        match = re.search(r'attacker_ip\s*=\s*([0-9\.]+)', sns_message)

        # 3. Safe escape: If there is no IP (like during a test or glitch), stop safely.
        if not match:
            logger.info("No valid IP address found in the alert. Ignoring.")
            return {
                'statusCode': 200,
                'body': 'No actionable IP found.'
            }

        # 4. Extract the IP!
        attacker_ip = match.group(1)
        logger.warning(f"Malicious IP detected: {attacker_ip}. Initiating automated response.")
        
        # 5. Execute the ban
        block_ip_in_waf(attacker_ip)
        
        return {
            'statusCode': 200,
            'body': f'SOAR Automated Response Completed. Blocked {attacker_ip}.'
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