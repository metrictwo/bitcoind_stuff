# Basic Terraform module to create an EC2 instance for running bitcoind. To
# keep most of the work of this project in Ansible, this will only create an
# instance and set up the security group to allow external nodes to connect to
# bitcoind. Installing Docker and running our container will be handled by
# Ansible.

# Find the most recent Amazon Linux 2 AMI in our region.
data "aws_ami" "al2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2017.12.*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# Capture default security group for use
data "aws_security_group" "default" {
  name = "default"
}

# Create a security group to allow other nodes to connect to our instance. For
# simplicity/security, JSON-RPC is not supported here.
resource "aws_security_group" "bitcoind" {
  name        = "bitcoind_${var.user}"
  description = "Allow external nodes to connect to bitcoind"
}

# Add an ingress rule for our security group.
resource "aws_security_group_rule" "bitcoind_in" {
  type        = "ingress"
  from_port   = 0
  to_port     = 8333
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bitcoind.id}"
}

# Create a free-tier EC2 instance in our default VPC/subnet.
resource "aws_instance" "bitcoind" {
  ami           = "${data.aws_ami.al2.id}"
  instance_type = "t2.micro"
  key_name      = "${var.key_name == "" ? var.user : var.key_name}"

  vpc_security_group_ids = [
    "${aws_security_group.bitcoind.id}",
    "${data.aws_security_group.default.id}",
  ]

  tags {
    Service = "bitcoind"
  }
}
