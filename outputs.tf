output "Webserver_public_ip" {
  value = aws_instance.Webserver.public_ip
}

output "Webserver_private_ip" {
  value = aws_instance.Webserver.private_ip
    
}
output "bastian_server_public_ip" {
  value = aws_instance.bastian.public_ip
  
}

output "rds_endpint" {
    value = aws_db_instance.rds_db.endpoint
  
}