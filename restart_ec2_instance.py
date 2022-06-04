import boto3
import json
import logging

EC2_REGION = "aws-region"
EC2_INSTANCE_ID = "your-instance-id"

logger = logging.getLogger(__name__)
ec2 = boto3.client("ec2", region_name=EC2_REGION)

def lambda_handler(event, context):
    logger.debug("New event received: " + json.dumps(event))
    ec2.reboot_instances(InstanceIds=[EC2_INSTANCE_ID])
    logger.debug("Restarted instance " + EC2_INSTANCE_ID)
