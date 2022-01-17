#variable "vpc_cidr_block" {}
#variable "subnet_cidr_block" {}
#variable "env_prefix" {}
#variable "my_ip" {}
variable "instance_type" {}
#variable "public_key_location" {}
#variable "windows_key" {}
#variable "subnet_id" {}
#variable "security_group_id" {}

provider "aws" {
  region = "us-east-1"
}

data "aws_vpc" "testvpc" {
  id = "vpc-087cd5393570c1fc1"
}

data "aws_subnet" "jenkins" {
  id = "subnet-0bbd96cf0a2f63d9a"
}

data "aws_security_group" "jenkins_sg" {
  id = "sg-0f0926b728a8a4eaf"
}


//create sonarqube security group
resource "aws_security_group" "sonar_test_sg" {
  name        = "mainsonarreposg"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.testvpc.id

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
  security_group_id        = "sg-0f0926b728a8a4eaf"
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
  source_security_group_id = "sg-0f0926b728a8a4eaf"
}

resource "aws_instance" "sonarqube_server" {

  ami           = "ami-0d80714a054d3360c"
  instance_type = var.instance_type
  #vpc_id                      = aws_vpc.main.id
  subnet_id                   = data.aws_subnet.jenkins.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sonar_test_sg.id]
  #key_name                    = aws_key_pair.windows-key.key_name
  key_name = "test"

}

resource "aws_security_group" "nexusrepo_test_sg" {
  name        = "mainnexusreposg"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.testvpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "SSH"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  tags = {
    Name = "mainnexusreposg"
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
#allowing jenkins security group in nexus security group. here source is jenkins and destination is nexus security group.
resource "aws_security_group_rule" "allow_jenkins_test_sg" {

  type                     = "ingress"
  description              = "SSH"
  from_port                = 8081
  to_port                  = 8081
  protocol                 = "tcp"
  security_group_id        = aws_security_group.nexusrepo_test_sg.id #to
  source_security_group_id = "sg-0f0926b728a8a4eaf"                  #from


}

resource "aws_security_group_rule" "allow_nexus_test_sg" {

  type                     = "ingress"
  description              = "SSH"
  from_port                = 8081
  to_port                  = 8081
  protocol                 = "tcp"
  security_group_id        = "sg-0f0926b728a8a4eaf"
  source_security_group_id = aws_security_group.nexusrepo_test_sg.id


}
resource "aws_instance" "nexus_server" {

  ami           = "ami-0ed9277fb7eb570c9"
  instance_type = var.instance_type[1]
  #vpc_id                      = aws_vpc.main.id
  subnet_id                   = data.aws_subnet.jenkins.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.nexusrepo_test_sg.id]
  key_name                    = "test"

  #user_data = file("nexus-setup.sh")


  tags = {
    Name = "nexus_server"
  }


}

resource "aws_security_group" "tomcat_sg" {
  name        = "application backend staging"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.testvpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  ingress {
    description = "All Traffic"
    protocol    = "tcp"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    self        = true

  }
  ingress {
    description = "SSH"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "vprofile_app_staging"
  }
}
resource "aws_security_group_rule" "allow_jenkins_stg_sg" {

  type                     = "ingress"
  description              = "SSH"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = aws_security_group.tomcat_sg.id #to
  source_security_group_id = "sg-0f0926b728a8a4eaf"          #from


}

resource "aws_security_group_rule" "allow_tomcat_jenkins_sg" {

  type                     = "ingress"
  description              = "SSH"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = "sg-0f0926b728a8a4eaf"
  source_security_group_id = aws_security_group.tomcat_sg.id

}
resource "aws_instance" "tomcat_server" {

  ami           = "ami-04505e74c0741db8d"
  instance_type = var.instance_type[0]
  #vpc_id                      = aws_vpc.main.id
  subnet_id                   = data.aws_subnet.jenkins.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.tomcat_sg.id]
  key_name                    = "test"

  #user_data = file("tomcat-setup.sh")


  tags = {
    Name = "tomcat_server"
  }

}
