variable "aws_region" {
  description = "The AWS region to create resources in."
  default     = "ap-south-1"
}

variable "rule_name" {
  description = "The name of the CloudWatch Event Rule"
  default     = "tf-example-cloudwatch-event-rule-for-kinesis"
}

variable "iam_role_name" {
  description = "The name of the IAM Role"
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
	default = "/home/madhu/.aws/keys/Priyank.pem"
}

