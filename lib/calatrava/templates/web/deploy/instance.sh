#!/bin/bash

touch /home/ubuntu/setup.log

sudo apt-get update >> /home/ubuntu/setup.log
sudo apt-get --yes install apache2 >> /home/ubuntu/setup.log
sudo a2enmod proxy >> /home/ubuntu/setup.log
sudo a2enmod proxy_http >> /home/ubuntu/setup.log
sudo a2enmod ssl >> /home/ubuntu/setup.log
sudo service apache2 start >> /home/ubuntu/setup.log
