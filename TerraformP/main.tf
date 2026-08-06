resource "aws_vpc" "kadel" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.kadel.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true


}


resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.kadel.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.kadel.id


}

resource "aws_route_table" "my_route" {
  vpc_id = aws_vpc.kadel.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_route_table_association" "assroute1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.my_route.id

}

resource "aws_route_table_association" "assroute2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.my_route.id

}


resource "aws_security_group" "secure" {
  name   = "onisowo"
  vpc_id = aws_vpc.kadel.id

  ingress {
    description = "TLS from VPC"
    protocol    = "tcp"
    self        = true
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    description = "SSH"
    protocol    = "tcp"
    self        = true
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "onisowo"
  }
}

resource "aws_s3_bucket" "joyadeleye13434343" {
  bucket = "undefined13434343"

}

resource "aws_s3_bucket_public_access_block" "joyadeleye13434343" {
  bucket = aws_s3_bucket.joyadeleye13434343.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_instance" "Arike1" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.secure.id]
  subnet_id              = aws_subnet.sub1.id
  user_data_base64       = base64encode(file("expose.sh"))

}


resource "aws_instance" "Arike2" {
  ami                    = "ami-0b6d9d3d33ba97d99"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.secure.id]
  subnet_id              = aws_subnet.sub2.id
  user_data_base64       = base64encode(file("expose2.sh"))

}

resource "aws_lb" "myalb" {
  name               = "myalb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.secure.id]
  subnets            = [aws_subnet.sub1.id, aws_subnet.sub2.id]


}

resource "aws_lb_target_group" "tg" {
  name     = "myTG"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.kadel.id

  health_check {
    path = "/"
    port = "traffic-port"
  }

}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.Arike1.id
  port             = 80

}



resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = aws_instance.Arike2.id
  port             = 80

}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.myalb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }

}

output "loadbalancerdns" {
  value = aws_lb.myalb.dns_name

}
