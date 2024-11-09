resource "aws_route53_record" "jenkins" {
  zone_id = "Z0812569WT2WJRN5HTSJ" 
  name    = "jenkins.aws.alextonkovid.site"
  type    = "A"
  ttl     = "300"
  records = [data.aws_eip.nat_eip.public_ip]
}

resource "aws_route53_record" "wordpress" {
  zone_id = "Z0812569WT2WJRN5HTSJ" 
  name    = "wordpress.aws.alextonkovid.site"
  type    = "A"
  ttl     = "300"
  records = [data.aws_eip.nat_eip.public_ip]
}