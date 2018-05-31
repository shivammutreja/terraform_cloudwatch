variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "ap-south-1"
}

variable "host_user" {
  description = "Username of the instance, like - ubuntu, ec2-user etc."
  default = "ubuntu"
}

variable "host_ip" {
  description = "Ip of the instance to run this file on"
  default = "0.0.0.0"
}

variable "source_cloudwatch_config" {
  description = "Path of the cloudwatch config file on local"
  default = "~/cloudwatch_config.conf"
}

variable "rule_name" {
  description = "The name of the CloudWatch Event Rule"
  default     = "tf-example-cloudwatch-event-rule-for-kinesis"
}

variable "iam_role_name" {
  description = "The name of the IAM Role to create"
  default     = "tf-example-iam-role-for-kinesis"
}

variable "target_name" {
  description = "The name of the CloudWatch Event Target"
  default     = "tf-example-cloudwatch-event-target-for-kinesis-flaskr"
}

variable "stream_name" {
  description = "The name of the Kinesis Stream to send events to"
  default     = "tf-example-kinesis-stream-flaskr"
}

variable "log_group" {
	description = "Name of the log group where all the logs will be directed initially from the instance"
	default= "TestLogGroupFlaskr"
}

variable "log_stream" {
	description = "Name of the log stream, will be the part of a log group  where all the filtered logs will be streamed from the instance"
	default= "StreamFlaskr"
}

variable "keyfile" {
	description = "Path of the pem file to apply remote-exec"
	default = "~/.aws/keys/public_key.pem"
}

