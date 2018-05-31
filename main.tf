provider "aws" {
	region = "${var.aws_region}"
}


provider "aws" {
	alias  = "northeast"
	region = "ap-northeast-1"
}


#TODO: Set variables for log group and log stream name 

resource "null_resource" "local" {
	provisioner "local-exec" {
		command = "sed -i 's/\\(log_group_name *= *\\).*/\\1 ${var.log_group}/' ${file(var.source_cloudwatch_config)}; sed -i 's/\\(log_stream_name *= *\\).*/\\1 ${var.log_stream}/' ${file(var.source_cloudwatch_config)}"
	}

	provisioner "file" {
		connection {
			user = "${var.host_user}"
			host = "${var.host_ip}"
			agent = true
			timeout = "3m"
			private_key = "${file(var.keyfile)}"
		}
		source      = "${file(var.source_cloudwatch_config)}"
		destination = "/home/${var.host_user}/cloudwatch_config.conf"
	}

	provisioner "remote-exec" {
		connection {
			user = "${var.host_user}"
			host = "${var.host_ip}"
			agent = true
			timeout = "3m"
			private_key = "${file(var.keyfile)}"
		}

		inline = [
			"curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O",
			"chmod +x ./awslogs-agent-setup.py",
			"sudo python3 awslogs-agent-setup.py -n -r ${var.aws_region} -c /home/${var.host_user}/cloudwatch_config.conf"
		]
	}
}


data "aws_caller_identity" "current" {}


resource "aws_s3_bucket" "bucket" {
	bucket = "tf-test-bucket-flaskr"
	acl    = "private"
}


resource "aws_iam_role" "firehose_role" {
	name = "firehose_test_role_flaskr"

	assume_role_policy = <<EOF
{
		"Version": "2012-10-17",
		"Statement": [
		{
			"Action": "sts:AssumeRole",
			"Principal": {
				"Service": "firehose.amazonaws.com"
				},
			"Effect": "Allow",
			"Condition": {
				"StringEquals": {
					"sts:ExternalId": "${data.aws_caller_identity.current.account_id}"
        }
      }
		}
			]
	}
EOF
}


resource "aws_iam_role_policy" "policy" {
	name = "tf-cloudwatch-policy-flaskr"
	role = "${aws_iam_role.firehose_role.id}"

	policy = <<POLICY
{
		"Version": "2012-10-17",
		"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:AbortMultipartUpload",
				"s3:GetBucketLocation",
				"s3:GetObject",
				"s3:ListBucket",
				"s3:ListBucketMultipartUploads",
				"s3:PutObject"
				],
			"Resource": [
				"${aws_s3_bucket.bucket.arn}",
				"${aws_s3_bucket.bucket.arn}/*"
				]
		}
			]
	}
POLICY
}


resource "aws_cloudwatch_log_group" "tf-log-group" {
  name = "${var.log_group}"

  tags {
    Environment = "staging"
  }
}


resource "aws_cloudwatch_log_stream" "tf-log-stream" {
  name           = "${var.log_stream}"
  log_group_name = "${aws_cloudwatch_log_group.tf-log-group.name}"
}


resource "aws_kinesis_firehose_delivery_stream" "test_stream" {
	provider    = "aws.northeast"
	name        = "terraform-kinesis-firehose-flaskr-stream-new"
	destination = "extended_s3"

	extended_s3_configuration {
		role_arn   = "${aws_iam_role.firehose_role.arn}"
		bucket_arn = "${aws_s3_bucket.bucket.arn}"
		cloudwatch_logging_options {
			enabled = false
			log_group_name = "${var.log_group}"
			log_stream_name = "${var.log_stream}"
		}
	}
}


resource "aws_iam_role" "logs-s3-role" {
	name = "logs_s3_tf_role_flaskr"

	assume_role_policy = <<EOF
{
	"Version": "2008-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Principal": {
				"Service": "logs.ap-south-1.amazonaws.com"
			},
			"Action": "sts:AssumeRole"
		}
	]
}
EOF
}


resource "aws_iam_role_policy" "logs-s3-policy" {
	name = "logs_s3_tf_policy_flaskr"
	role = "${aws_iam_role.logs-s3-role.id}"

	policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"firehose:*"
				],
			"Resource": [
				"${aws_kinesis_firehose_delivery_stream.test_stream.arn}"
				]
			},
			{
				"Effect": "Allow",
				"Action": [
					"iam:PassRole"
					],
				"Resource": [
					"${aws_iam_role.logs-s3-role.arn}"
					]
				}
		]
}
POLICY
}


resource "aws_cloudwatch_log_subscription_filter" "test_cw_s3_logfilter" {
	name            = "test_cw_s3_logfilter-flaskr-new"
	role_arn        = "${aws_iam_role.logs-s3-role.arn}"
	log_group_name  = "${var.log_group}"
	filter_pattern  = "[..., status_code!=200, size]"
	destination_arn = "${aws_kinesis_firehose_delivery_stream.test_stream.arn}"
	distribution    = "Random"
}

