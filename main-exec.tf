data "aws_ami" "pro2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}
resource "aws_instance" "local-ec2" {
  ami           = data.aws_ami.pro2.id
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "echo ${aws_instance.local-ec2.public_ip} >> public_ips.txt"
  }
  tags = {
    "Name" = "local-exec"
  }
}

resource "aws_key_pair" "pro-key" {
  key_name   = "devops14-tf-key-1"
  public_key = file("${path.module}/my_public_key.txt")
}


resource "aws_instance" "remote-ec2" {
  ami                    = data.aws_ami.pro2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.pro-key.id
  vpc_security_group_ids = [aws_security_group.my-sg.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum install httpd -y",
      "sudo cd /var/www/html",
      "sudo wget https://devops14-mini-project.s3.amazonaws.com/default/index-default.html",
      "sudo wget https://devops14-mini-project.s3.amazonaws.com/default/mycar.jpeg",
      "sudo mv index-default.html index.html",
      "sudo systemctl start httpd",
      "sudo systemctl enable httpd --now"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./private_key.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_security_group" "my-sg" {
  name = "remote-ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals{
time =formatdate("DD MM YYYY hh:mm: ZZZ", timestamp())
}
output"timestamp"{
value =local.time
}

