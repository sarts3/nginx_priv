output "server-ip" {
  value = "${aws_instance.server.private_ip}"
}

output "modsec-ip" {
  value = "${aws_instance.modsec.private_ip}"
}
