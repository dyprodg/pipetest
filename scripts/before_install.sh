#!/bin/bash

# Stopping httpd service
service httpd stop

# Copying the latest index.html to httpd directory
cp /opt/codedeploy-agent/deployment-root/deployment-instructions/ /var/www/html/

# Restarting httpd service
service httpd start
