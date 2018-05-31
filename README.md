# terraform_cloudwatch
Terraform script to install, configure and run AWS cloudwatch agent on your EC2 instance.


We will be using ap-northeast-1 region for Firehose Kinesis. Make sure you're authorized to perform actions in that region.

Pre-requisites :-

1. A running ec2 instance.
2. Keys with appropriate IAM roles configured on the instance. (Run aws configure to configure this). 
3. Terraform installed on local. Follow - https://www.terraform.io/intro/getting-started/install.html
4. Cloudwatch config file created on local. A simple file can be found at - https://s3.ap-south-1.amazonaws.com/test-syslog/cloudwatch_config.conf


Steps to run :-

1. Clone this repo.

2. Make appropriate changes to the variables.tf file. You'll probably have to change the following variables : aws_region, host_user, host_ip, source_cloudwatch_config and keyfile.

3. Run terraform plan to see what all steps terraform will perform on the given host ip.

4. Make sure the host already has your aws keys configured and has permissions to AWS cloudwatch, Kinesis and S3 (write).

5. Run terraform apply. Terraform will prompt you to ask if the terraform plan is good to go. Type "yes" and press return. 

6. If this is for practice I would recommend you to destroy the architecture by running terraform destroy.

Caveats :- 

Running the script will create a few roles and permissions. 

AWS will eventually charge you some bucks for Cloudwatch and S3 if you forget to destroy the resource.

