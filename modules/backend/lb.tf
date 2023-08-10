locals {
  zone = var.testing ? "test.${var.zone}" : var.zone
}

resource "aws_lb_target_group" "this" {
  name                 = var.name
  port                 = var.container_port
  protocol             = "HTTP"
  vpc_id               = var.vpc_id
  target_type          = "ip"
  deregistration_delay = 0

  health_check {
    path                = var.health_check_path
    interval            = var.health_check_interval
    timeout             = 30
    healthy_threshold   = 2
    unhealthy_threshold = var.health_check_attempts
    matcher             = "200-299,301"
  }
}

resource "aws_lb_listener_rule" "app" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = distinct(["${var.zone_alias}.${var.zone}", "${var.host}"])
    }
  }
}

// route: redirect base path to tenant for host
resource "aws_lb_listener_rule" "app_https_routes" {
  for_each = { for route in var.routes : route.name => route }

  listener_arn = var.listener_arn

  action {
    type = "redirect"
    redirect {
      path        = each.value.path
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["${each.value.name}.${local.zone}"]
    }
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}

// route: allow supported routes for host
resource "aws_lb_listener_rule" "app_https_routes_supported" {
  for_each = { for route in var.routes : route.name => route }

  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  condition {
    host_header {
      values = ["${each.value.name}.${local.zone}"]
    }
  }

  condition {
    path_pattern {
      values = [
        "/cspace/${split(".", each.key)[0]}/*",
        "/cspace-services/*",
        "/cspace-ui/*",
        "/gateway*"
      ]
    }
  }
}
