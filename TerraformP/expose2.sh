#!/bin/bash

# Update system
apt update -y
apt install -y apache2 awscli

# Start and enable Apache
systemctl start apache2
systemctl enable apache2

# Get Instance Metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

#install the aws cli
apt install -y awscli

# Download image from S3
# ⚠️ Replace with your real bucket + image name
#aws s3 cp s3://YOUR-BUCKET-NAME/portfolio.jpg /var/www/html/images/portfolio.jpg

# Create Portfolio HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
<title>My Portfolio</title>
<style>
body {
  font-family: Arial;
  background-color: #f4f4f4;
  text-align: center;
}
.container {
  background: white;
  padding: 20px;
  margin: 40px auto;
  width: 70%;
  border-radius: 10px;
  box-shadow: 0px 0px 10px gray;
}
img {
  width: 300px;
  border-radius: 10px;
}
</style>
</head>

<body>
<div class="container">
<h1>🚀 ONISOWO SMART HUB LIMITED</h1>

<p><strong>Instance ID:</strong> $INSTANCE_ID</p>
<p><strong>Availability Zone:</strong> $AZ</p>

<h2>About Me</h2>
<p> ONISOWO SMART.</p>

<h2>My Image from S3</h2>
<img src="images/portfolio.jpg" alt="Portfolio Image">

</div>
</body>
</html>
EOF

# Fix permissions
chown -R www-data:www-data /var/www/html
# start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2
