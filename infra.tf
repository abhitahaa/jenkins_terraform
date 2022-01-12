
variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}
variable "windows_key" {}
variable "subnet_id" {}
variable "security_group_id" {}


data "aws_subnet" "jenkins" {
  id = var.subnet_id
}



data "aws_security_group" "jenkins_sg" {
  id = var.security_group_id
}


//create sonarqube security group
resource "aws_security_group" "sonar_test_sg" {
  name        = "mainsonarreposg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "SSH"
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "SSH"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  tags = {
    Name = "mainsonarreposg"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}


//from jenkins to sonar

resource "aws_security_group_rule" "allow_sonar_test_sg" {

  type                     = "ingress"
  description              = "SSH"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = data.security_group_id.jenkins_sg.id
  source_security_group_id = aws_security_group.sonar_test_sg.id

}
//form sonar to jenkins

resource "aws_security_group_rule" "allow_jenkins_from_sonar_sg" {

  type                     = "ingress"
  description              = "SSH"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.sonar_test_sg.id
  source_security_group_id = data.security_group_id.jenkins_sg.id
}

resource "aws_instance" "sonarqube_server" {

  ami           = "ami-0d80714a054d3360c"
  instance_type = var.instance_type[0]
  #vpc_id                      = aws_vpc.main.id
  subnet_id                   = data.aws_subnet.jenkins.cidr_block
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sonar_test_sg.id]
  #key_name                    = aws_key_pair.windows-key.key_name
  key_name  = "test"
  tags = {
    Name = "${var.env_prefix}-windows-server"
  }

}