resource "aws_lb" "seoul_alb" {
  name               = "seoul-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.seoul_private_subnet1.id, aws_subnet.seoul_private_subnet2.id]

  tags = {
    Name = "seoul-alb"
    Environment = "development"
  }
}

resource "aws_lb_target_group" "alb_target" {
  name     = "seoul-alb-target-group"
  port     = 80                                 # ALB-WEB doesn't need 443(HTTP) because of offloading
  protocol = "HTTP"
  vpc_id   = aws_vpc.seoul.id
  slow_start = 30
}

resource "aws_lb_target_group_attachment" "alb_target_attach" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = aws_instance.web_instance1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "alb_target_attach2" {
  target_group_arn = aws_lb_target_group.alb_target.arn
  target_id        = aws_instance.web_instance2.id
  port             = 80
}


resource "aws_lb_listener" "ex_alb_listener_http" {
  load_balancer_arn = aws_lb.seoul_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target.arn
  }
}
