#!/usr/bin/env bash
# safe header missing
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# script not informative

API_KEY=${API_KEY:-changeme}
VERSION=${VERSION:-1.0.0}
PORT=${PORT:-5000}

docker build -t status-dashboard .

docker stop status-dashboard || true
docker rm status-dashboard || true

docker run -d \
--name status-dashboard \
--restart unless-stopped \
-p 127.0.0.1:5000:5000 \
-e API_KEY="$API_KEY" \
-e VERSION="$VERSION" \
-e PORT="$PORT" \
status-dashboard

cp nginx/status-dashboard /etc/nginx/sites-available/status-dashboard

ln -sf /etc/nginx/sites-available/status-dashboard \
/etc/nginx/sites-enabled/status-dashboard

rm -f /etc/nginx/sites-enabled/default

nginx -t

systemctl enable nginx
systemctl restart nginx
# missing stucture
echo "Installation completed successfully"
echo "Service available at: http://localhost/"
