# Lambda EC2 Periodic Restart

Restart your EC2 instance every Saturday at 00:00 hours because it's weekend baby!


### How it works?

Cloudwatch Event invokes lambda function that restarts EC2 instance using Boto3.
What else would you need?


### How to use?

1. Make sure to replace the instance ID, instance ARN and AWS region in the Python and JSON file
1. `./configure.sh`
