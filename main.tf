## local value
locals {
  project = "Webserver"
}

## Creating vpc 
resource "aws_vpc" "main" {

  cidr_block           = "10.1.0.0/16"
  enable_dns_hostnames = true
  tags = {

    Name = "${local.project} Project"

  }

}

## creating three public subnets

resource "aws_subnet" "public_subnets" {

  count = length(var.public_subnet_webserver)

  vpc_id = aws_vpc.main.id

  cidr_block = element(var.public_subnet_webserver, count.index)

  availability_zone = element(var.azs, count.index)

  tags = {

    Name = "Public Subnet ${local.project} ${count.index + 1}"

  }

}

## creating three private subnets

resource "aws_subnet" "private_subnets" {

  count = length(var.private_subnet_webserver)

  vpc_id = aws_vpc.main.id

  cidr_block = element(var.private_subnet_webserver, count.index)

  availability_zone = element(var.azs, count.index)

  tags = {

    Name = "Private Subnet ${local.project} ${count.index + 1}"

  }

}

## creating internet gateway for VPC
resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.main.id

  tags = {

    Name = "${local.project} Project VPC IG"

  }

}

## route table for non local traffic
resource "aws_route_table" "second_rt" {

  vpc_id = aws_vpc.main.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.gw.id

  }

  tags = {

    Name = "${local.project} 2nd Route Table"

  }

}

## associating public subnets to second route table which will route non local traffic to internet
resource "aws_route_table_association" "public_subnet_asso" {

  count = length(var.public_subnet_webserver)

  subnet_id = element(aws_subnet.public_subnets[*].id, count.index)

  route_table_id = aws_route_table.second_rt.id

}

## data block to get latest ami
data "aws_ami" "WebserverAMI" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

## webserver security group
resource "aws_security_group" "webserver" {
   vpc_id = aws_vpc.main.id
   egress {
         from_port   = 0
         to_port     = 0
         protocol    = "-1"
         cidr_blocks = ["0.0.0.0/0"]
       }
}

## webserver security group ingress rules association
resource "aws_security_group_rule" "sg_ingress_rules" {
  count = length(var.sg_ingress_rules)

  type              = "ingress"
  from_port         = var.sg_ingress_rules[count.index].from_port
  to_port           = var.sg_ingress_rules[count.index].to_port
  protocol          = var.sg_ingress_rules[count.index].protocol
  cidr_blocks       = [var.sg_ingress_rules[count.index].cidr_block]
  description       = var.sg_ingress_rules[count.index].description
  security_group_id = aws_security_group.webserver.id
}

## Webserver instance
resource "aws_instance" "Webserver" {

  ami                         = data.aws_ami.WebserverAMI.id
  subnet_id                   = aws_subnet.public_subnets[0].id
  instance_type               = "t2.micro"
  key_name                    = var.Keypair
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.webserver.id]
  user_data                   = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  sudo apt install mysql-server -y
  sudo apt install php-cgi -y
  sudo apt install php-mysql -y
  sudo apt-get install libapache2-mod-php -y
  sudo service apach2 restart
  sudo cp /usr/lib/php/8.1/php.ini-production /usr/local/lib/php.ini
  EOF

  tags = {
    Name = "Webserver"
  }

}

## RDS security group
resource "aws_security_group" "rds_sg" {
  vpc_id = "vpc-0d989b7912dc1864d"
  name   = "rds_sg"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.webserver.id}"]
  }
}

## rds subnet group
resource "aws_db_subnet_group" "default" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  tags = {
    Name = "${local.project} Project"
  }
}

## rds instance
resource "aws_db_instance" "rds_db" {
  identifier             = "webser-db"
  instance_class         = "db.t2.micro"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "5.7"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  db_name                = "webserver"
  username               = "webserver"
  password               = "webserver"
  parameter_group_name   = "default.mysql5.7"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = true
  publicly_accessible    = true
}

## bastian host security group
resource "aws_security_group" "bastian_sg" {

  vpc_id = "vpc-0d989b7912dc1864d"
  name   = "bastian_sg"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

## bastian host instance
resource "aws_instance" "bastian" {
  ami                         = data.aws_ami.WebserverAMI.id
  subnet_id                   = aws_subnet.public_subnets[0].id
  instance_type               = "t2.micro"
  key_name                    = var.Keypair
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.bastian_sg.id]
  
}

