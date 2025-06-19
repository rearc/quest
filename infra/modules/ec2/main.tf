data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.prefix}/vpc/id"
}

data "aws_ssm_parameter" "subnet" {
  name = "/${var.prefix}/subnet/a/id"
}

data "aws_ssm_parameter" "subnet_b" {
  name = "/${var.prefix}/subnet/b/id"
}

locals {
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  subnet_a_id = data.aws_ssm_parameter.subnet.value
  subnet_b_id = data.aws_ssm_parameter.subnet_b.value
}

resource "aws_security_group" "ssh_access" {
  vpc_id      = local.vpc_id
  name        = "${var.prefix}-ssh-access"
  description = "SSH access group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "Allow SSH"
    createdBy = "${var.prefix}/ssh-access"
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.root}/id_rsa"
  file_permission = "0600"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.prefix}-web-key"
  public_key = tls_private_key.ssh_key.public_key_openssh

  tags = {
    Name = "${var.prefix}-web-key"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "web_server_sg" {
  vpc_id      = local.vpc_id
  name        = "${var.prefix}-web-server-sg"
  description = "SG for web-server"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-web-server-sg"
  }
}

resource "aws_instance" "web_server" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.ssh_key.key_name
  subnet_id                   = local.subnet_a_id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.web_server_sg.id,
    aws_security_group.ssh_access.id
  ]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name = "${var.prefix}-web-server"
  }
}

resource "null_resource" "web_server_provision" {
  depends_on = [aws_instance.web_server]

  connection {
    host        = aws_instance.web_server.public_ip
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ssh_key.private_key_pem
  }

  provisioner "file" {
    source      = "${path.module}/docker_install.sh"
    destination = "/home/ubuntu/docker_install.sh"
  }

  provisioner "file" {
    source      = "${path.module}/provision-node-app.sh"
    destination = "/home/ubuntu/provision-node-app.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ubuntu/docker_install.sh /home/ubuntu/provision-node-app.sh",
      "/home/ubuntu/docker_install.sh",
      "/home/ubuntu/provision-node-app.sh ${var.docker_image} ${var.secret_word}"
    ]
  }
}
