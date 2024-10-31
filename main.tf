resource "aws_vpc" "myvpc" {
  cidr_block = var.cidr
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.cidr_block1
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "sub2" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = var.cidr_block2
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "myigw" {
    vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "myrt" {
  vpc_id = aws_vpc.myvpc.id

 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
}

resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.sub2.id
  route_table_id = aws_route_table.myrt.id
}

resource "aws_security_group" "mysg" {
  name = "mysg"
  vpc_id = aws_vpc.myvpc.id

  ingress {
    description = "HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysg"
  }
}

resource "aws_s3_bucket" "mys3bucket" {
    bucket = "ridwanulahiafolabiterraform2020project" 
}

resource "aws_instance" "server1" {
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.mysg.id ]
  subnet_id = aws_subnet.sub1.id
  user_data = base64encode(file("userdata.sh"))
}

resource "aws_instance" "server2" {
  ami = var.ami
  instance_type = var.instance_type
  vpc_security_group_ids = [ aws_security_group.mysg.id ]
  subnet_id = aws_subnet.sub2.id
  user_data = base64encode(file("userdata1.sh"))
}

#create application load balancer (ALB)
resource "aws_alb" "myalb" {
  name = "myalb"
  internal = false
  load_balancer_type = "application"

  security_groups = [ aws_security_group.mysg.id ]
  subnets = [ aws_subnet.sub1.id, aws_subnet.sub2.id ]

  tags = {
    Name = "myalb"
  }
}

resource "aws_lb_target_group" "mytg" {
  name = "mytg"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.myvpc.id

  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group_attachment" "attach1" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id = aws_instance.server1.id
  port = 80
}

resource "aws_lb_target_group_attachment" "attach2" {
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id = aws_instance.server2.id
  port = 80
}

resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_alb.myalb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.mytg.arn
    type = "forward"
  }
}