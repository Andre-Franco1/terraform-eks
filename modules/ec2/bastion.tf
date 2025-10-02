resource "aws_security_group" "bastion_sg" {
  description = "Allow SSH from outside"
  vpc_id      = var.vpc

  ingress {
    description = "SSH from outside"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  associate_public_ip_address = true
  key_name                    = aws_key_pair.bastion_ssh.id
  subnet_id                   = var.public_subnet_1a
  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]
  user_data = <<EOF
#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y ansible
EOF

  tags = merge(
    var.tags,
    { "Name" : "bastion" }
  )
}