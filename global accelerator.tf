resource "aws_globalaccelerator_accelerator" "GA" {
  name            = "GA"
  ip_address_type = "IPV4"
  enabled         = true

}


resource "aws_globalaccelerator_listener" "GA_listener" {
  accelerator_arn = aws_globalaccelerator_accelerator.GA.id
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }
}


resource "aws_globalaccelerator_endpoint_group" "GA_group" {
  listener_arn = aws_globalaccelerator_listener.GA_listener.id

  endpoint_configuration {
    endpoint_id = aws_lb.seoul_alb.arn

  }
}
