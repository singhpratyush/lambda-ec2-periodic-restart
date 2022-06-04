#!/bin/bash

# Create a role that will run the lambda function
# With permission to reboot the EC2 instance
aws iam create-role --role-name lambda-ec2-restart-executor --assume-role-policy-document '{"Version": "2012-10-17","Statement": [{ "Effect": "Allow", "Principal": {"Service": "lambda.amazonaws.com"}, "Action": "sts:AssumeRole"}]}'
aws iam attach-role-policy --role-name lambda-ec2-restart-executor --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
aws iam attach-role-policy --role-name lambda-ec2-restart-executor --assume-role-policy-document file://reboot-permission-policy.json
IAM_ROLE_ARN=`aws iam get-role --role-name lambda-ec2-restart-executor --query 'Role.[Arn]' --output text`


# Create the lambda function
zip function.zip restart_ec2_instance.py
aws lambda create-function \
    --function-name RestartEC2Instance \
    --zip-file fileb://function.zip \
    --handler restart_ec2_instance.lambda_handler \
    --runtime python3.9 \
    --role $IAM_ROLE_ARN
LAMBDA_FUNCTION_ARN=`aws lambda get-function --function-name RestartEC2Instance --query 'Configuration.[FunctionArn]' --output text`


# Create a Cloudwatch Event Rule and make it invoke the function
aws events put-rule \
    --name every-saturday-at-0-hour \
    --schedule-expression 'cron(0 0 * * 6)'
RULE_ARN=`aws events describe-rule --name every-saturday-at-0-hour --query 'Arn' --output text`

aws lambda add-permission \
    --function-name RestartEC2Instance \
    --statement-id every-saturday-at-0-hour \
    --action 'lambda:InvokeFunction' \
    --principal events.amazonaws.com \
    --source-arn $RULE_ARN

aws events put-targets --rule every-saturday-at-0-hour --targets "Id"="1","Arn"="$LAMBDA_FUNCTION_ARN"
