resource "aws_route53_record" "sonar" {
  zone_id = "Z0812569WT2WJRN5HTSJ" 
  name    = "prometheus.aws.alextonkovid.site"
  type    = "A"
  ttl     = "300"
  records = [data.aws_eip.nat_eip.public_ip]
}