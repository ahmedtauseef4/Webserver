## Introduction
This is a small project which uses terraform to create following infrastructure:
 > VPC
 > Subnets
 > Routing tables
 > Route table associations
 > Internet gateway
 > Security groups
 > EC2 instance
 > RDS mysql db
 > Bastian host
 
## Instructions

1. add your access key and secret key to providers.tf 
2. check varables.tf and make changes according to your plan // please change region and keypair name accordingly
3. run terraform commands [init,fmt,validate,plan]
4. run terraform apply if everythings looks good and ssh to ec2 // ssh -i keypair.pem ubuntu@hostname
5. after infrastructure is ready, connect to rds(mysql db) using below command:
     mysql --host=<replace it with rds endpoint> --user=webserver --password=webserver webserver
6. create city table and insert record(s) using create_city.sql
7. Navigate to /var/www/html and create get_city.php
8. PDO-mysql is used by php script
9. visit apache website using ec2 public ip or route53 public hostname e.g http://18.133.246.81/get_city.php