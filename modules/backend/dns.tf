resource "aws_route53_record" "app_routes" {
  for_each = { for route in local.routes : route.name => route }

  provider = aws.dns

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${each.key}.${local.zone}"
  type    = "A"

  alias {
    name                   = data.aws_lb.selected.dns_name
    zone_id                = data.aws_lb.selected.zone_id
    evaluate_target_health = true
  }
}
