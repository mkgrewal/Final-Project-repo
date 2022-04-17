#!/bin/bash
#yum -y update
#yum -y install httpd
#myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
#echo "<h1>Welcome to ACS730 ${prefix}! My private IP is $myip <font color="turquoise"> in ${env} environment</font></h1><br>Built by Terraform!"  >  /var/www/html/index.html
#sudo systemctl start httpd
#sudo systemctl enable httpd

!/bin/bash
yum update -y
yum install -y httpd.x86_64
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
echo "<h1>Welcome to ACS730. Group 7- Dev-VPC. Manpreet, Karim,Swapneet, Romiya. My private IP is $myip <font color="turquoise"> <font color="turquoise"> in STAGE environment</font></h1><br>Built by Terraform! <br> <img src='https://images18.s3.amazonaws.com/MicrosoftTeams-image+(2).png'/> " > /var/www/html/index.html

sudo systemctl start httpd
sudo systemctl enable httpd