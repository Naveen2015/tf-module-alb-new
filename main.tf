resource "aws_security_group" "sg" {
  name        = "${var.name}-alb-${var.env}-sg"
  description = "${var.name}-alb-${var.env}-sg"
  vpc_id      = var.vpc_id
  ingress {
    description = "APP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = var.allow_alb_cidr

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = { Name = "${var.name}-${var.env}-sg" }
}

resource "aws_lb" "main" {
  name               = "${var.name}-${var.env}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.subnets
  tags = { Name = "${var.name}-${var.env}-alb" }
}



resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "unauthorized"
      status_code  = "404"
    }
  }
}

