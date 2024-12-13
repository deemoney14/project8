provider "aws" {
  region = "us-west-1"

}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main_gx_vpc"
  }


}
#public subnet

resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = "us-west-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_1a"
  }

}

#IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }

}

resource "aws_route_table" "route_public1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "route_public1"
  }
}

#public route assoc

resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.route_public1.id

}

resource "aws_instance" "public_server" {
  ami                         = "ami-04fdea8e25817cd69"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1a.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.public_sg.id]

  tags = {
    Name = "public_server"
  }
}

resource "aws_security_group" "public_sg" {
  name        = "public_sg"
  description = "allow HTTP acess over the web"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "public_sg"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
#ebs
resource "aws_ebs_volume" "public_volume" {
  availability_zone = "us-west-1a"
  size              = 8

  tags = {
    Name = "public_volume"
  }

}

#ebs attached
resource "aws_volume_attachment" "public_attachment" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.public_volume.id
  instance_id = aws_instance.public_server.id

}
#ebs snapshot
resource "aws_ebs_snapshot" "public_snapshot" {
  volume_id = aws_ebs_volume.public_volume.id

  tags = {
    Name = "public_snapshot"
  }

}