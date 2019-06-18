provider "aws" {
  region  = "eu-west-1"
  profile = "DeepRacer"
}
####Creation du Bucket S3
resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-bfffucket-one"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
####Création d'un VPC avec la plage 10.65.20.0/22
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.65.20.0/22"

  tags = {
    Name = "VPC_LAB"
  }
}
####Création de subnet Public A
resource "aws_subnet" "Public_A" {
  vpc_id            = "${aws_vpc.my_vpc.id}" 
  cidr_block        = "10.65.20.0/27"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Public_A"
  }
}
####Création de subnet Public A
resource "aws_subnet" "Public_B" {
  vpc_id            = "${aws_vpc.my_vpc.id}" 
  cidr_block        = "10.65.20.32/27"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Public_B"
  }
}
resource "aws_subnet" "Private_A" {
  vpc_id            = "${aws_vpc.my_vpc.id}" 
  cidr_block        = "10.65.20.128/27"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Private_A"
  }
}
resource "aws_subnet" "Private_B" {
  vpc_id            = "${aws_vpc.my_vpc.id}" 
  cidr_block        = "10.65.20.160/27"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "Private_B"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"
    tags = {
    Name = "Internet_Gateway"
  }
}
 
resource "aws_eip" "Elastic_IP" {
  vpc      = true
  #instance="${aws_instance.test_instance.id}"
  
} 
 


resource "aws_nat_gateway" "gw" {
 allocation_id = "${aws_eip.Elastic_IP.id}"
 subnet_id     = "${aws_subnet.Private_A.id}"
  tags = {
  Name = "NAT_Gateway"
  }
}

######
resource "aws_route_table" "Route_Table1" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "10.65.20.0/22"
    gateway_id = "${aws_vpc.my_vpc.id}"
  }
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
  tags = {
    Name = "Route_Table1"
  }
}
####
resource "aws_route_table" "Route_Table2" {
  vpc_id = "${aws_vpc.my_vpc.id}"

  route {
    cidr_block = "10.65.20.0/22"
    gateway_id = "${aws_vpc.my_vpc.id}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }

}
#####
resource "aws_route_table_association" "subnet-association" {

  subnet_id      = "${aws_subnet.Public_A.id}"
  route_table_id = "${aws_route_table.Route_Table1.id}"
}

#####

resource "aws_network_interface" "Network_Interface" {
  subnet_id   = "${aws_subnet.Private_A.id}"
  #private_ips = ["10.65.20.130"]

  tags = {
    Name = "primary_network_interface"
  }
}

resource "aws_instance" "test_instance" {
  # us-west-2
  ami           = "ami-01f3682deed220c2a"
  instance_type = "t2.micro"
  
  #associate_public_ip_address="${aws_internet_gateway.gw.id}"
  subnet_id = "${aws_subnet.Private_A.id}"
}

  /*network_interface {
    network_interface_id = "${aws_network_interface.Network_Interface.id}"
    


}*/