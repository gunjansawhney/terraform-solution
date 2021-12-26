/*==== Output ======*/

output "elb_id" {
  value =join("",aws_elb.web_elb[*].id )
}

output "elb_dns" {
  value = aws_elb.web_elb.dns_name
}

output "sg_id" {
  value = aws_security_group.elb_http.id
}