resource "aws_route53_zone" "seoul_zone" {
  name = "aws-seoul.interal"

  vpc {
    vpc_id = aws_vpc.seoul.id
  }
}


resource "aws_route53_record" "A_seoul" {
  zone_id = aws_route53_zone.seoul_zone.zone_id
  name    = "web1-aws-seuol-internal"
  type    = "A"
  ttl     = "300"
  records = ["10.1.3.100"]
}


resource "aws_route53_zone_association" "seoul_attch" {
  zone_id = aws_route53_zone.seoul_zone.zone_id
  vpc_id  = aws_vpc.seoul.id
}
