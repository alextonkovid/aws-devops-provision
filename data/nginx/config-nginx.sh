#!/bin/bash

# Set variables
CONFIG_SOURCE="/tmp/nginx/conf.d"
CONFIG_DESTINATION="/etc/nginx/"

echo "Update repo"
sudo yum update -y

echo "Installing nginx"
sudo yum install -y nginx


# Start NGINX
if sudo service nginx start; then
    echo "NGINX start command executed successfully"
else
    echo "Failed to srart NGINX"
    exit 1
fi

echo "NGINX Started"

echo "Starting NGINX configuration update"

# Step 1: Copy the configuration file
if sudo cp -r "$CONFIG_SOURCE" "$CONFIG_DESTINATION"; then
    echo "Copied nginx.conf to $CONFIG_DESTINATION"
else
    echo "Copy failed"
    exit 1
fi

# Step 2: Test the NGINX configuration
if sudo nginx -t; then
    echo "NGINX configuration test passed"
else
    echo "NGINX configuration test failed"
    exit 1
fi

# Step 3: Reload NGINX
if sudo service nginx reload; then
    echo "NGINX reload command executed successfully"
else
    echo "Failed to reload NGINX"
    exit 1
fi

echo "NGINX configuration update completed"
