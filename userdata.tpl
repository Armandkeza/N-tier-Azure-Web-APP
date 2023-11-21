#! /usr/bin/env bash

set -euo pipefail
echo " [INFO] Installing apache2"
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

echo "[INFO] Creating index.html"
cat > /var/www/html/index.html << EOF
    <h1>${heading_one}</h1>
EOF