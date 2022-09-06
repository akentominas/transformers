output "load_balancer_link" {
  value = aws_elb.transifex-lb.dns_name
}
