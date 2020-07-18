//provide the credential
provider "aws" {
  region   = "ap-south-1"
  access_key = "your_access_key"
  secret_key = "your_secret_key"
  profile  = "sachin"
}

//create vpc
resource "aws_vpc" "skvpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames  = true

  tags = {
    Name = "task4_vpc"
  }
}

//create a subnets
resource "aws_subnet" "sksubnet1-1a" {
  vpc_id     = "${aws_vpc.skvpc.id}"
  cidr_block = "192.168.0.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "Subnet1-1a"
  }
}
resource "aws_subnet" "sksubnet2-1b" {
  vpc_id     = "${aws_vpc.skvpc.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "Subnet2-1b"
  }
}

//create a internet gateway
resource "aws_internet_gateway" "sk_internet_gateway" {
  vpc_id = "${aws_vpc.skvpc.id}"

  tags = {
    Name = "Internet_Gateway"
  }
}
//create a route table
resource "aws_route_table" "sk_route_table" {
  vpc_id = "${aws_vpc.skvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.sk_internet_gateway.id}"
  }

 

  tags = {
    Name = "sk_route_table"
  }
}
//create a route table association
resource "aws_route_table_association" "sk_route_association" {
  subnet_id      = aws_subnet.sksubnet1-1a.id
  route_table_id = aws_route_table.sk_route_table.id
}
// create a security group
resource "aws_security_group" "webserver" {
  name        = "for_wordpress"
  description = "Allow hhtp"
  vpc_id      = "${aws_vpc.skvpc.id}"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  ingress {
    description = "SSH"
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

  tags = {
    Name = "sk_sg"
  }
}
//create a netgateway
resource "aws_eip" "nat" {
  vpc=true
  
}
resource "aws_nat_gateway" "nat-gw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.sksubnet1-1a.id}"
  depends_on = [aws_internet_gateway.sk_internet_gateway]

  tags = {
    Name = "Nat_Gateway"
  }
}
//create route for private server
resource "aws_route_table" "private_route" {
  vpc_id = "${aws_vpc.skvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.nat-gw.id}"
  }

 

  tags = {
    Name = "fordatabase"
  }
}
resource "aws_route_table_association" "nat" {
  subnet_id      = aws_subnet.sksubnet2-1b.id
  route_table_id = aws_route_table.private_route.id
}
//create mysql sg
resource "aws_security_group" "database" {
  name        = "for_MYSQL"
  description = "Allow MYSQL"
  vpc_id      = "${aws_vpc.skvpc.id}"

  ingress {
    description = "MYSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.webserver.id]
   
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySQL_sg"
  }
}
resource "aws_instance" "wordpress" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.sksubnet1-1a.id
  vpc_security_group_ids = [aws_security_group.webserver.id]
  key_name = "eks"
  

  tags = {
    Name = "wordpress_server"
  }

}
resource "aws_instance" "mysql" {
  ami           = "ami-0019ac6129392a0f2"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.sksubnet2-1b.id
  vpc_security_group_ids = [aws_security_group.database.id]
  key_name = "eks"
  

 tags = {
    Name = "mysql_server"
  }

}
