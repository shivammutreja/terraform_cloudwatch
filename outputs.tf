output "firehose_stream_arn" {
	value = "${aws_kinesis_firehose_delivery_stream.test_stream.arn}"
}
