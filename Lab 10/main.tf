data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.10.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "cloud-tech-vpc"
  }
}

resource "aws_internet_gateway" "gw" {

  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = format("public-%d", count.index)
    Tier = "Public"
  }

}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "route-table-public"
  }
}

resource "aws_route_table_association" "subnet_association_public" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.public.*.id[count.index]
  route_table_id = aws_route_table.route_table.id
}

# SG
resource "aws_security_group" "ec2" {
  name        = "ec2"
  description = "ec2"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "http"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  tags = {
    Name = "allow HTTP"
  }
}

# EC2
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [ "amzn2-ami-kernel-5.10-hvm-2.0.20220606.1-x86_64-gp2" ]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.public[0].id
  associate_public_ip_address = true
  user_data = <<-EOF
    set -ex
    sudo yum update -y
    sudo amazon-linux-extras install docker -
    sudo usermod -a -G docker ec2-user
    sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo service docker start
    docker network create -d bridge net
    docker run -d --name wordpress_mysql --network net clodtech52/lab9:wordpress-mysql
    docker run -d --name wordpress_nginx --network net -p 80:80 cloudtech52/lab9:wordpress-nginx
  EOF

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  tags = {
    Name = "lab9-ec2"
  }
}