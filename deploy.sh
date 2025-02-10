#!/bin/bash

# Pindah ke direktori kerja Jenkins
cd /var/lib/jenkins/workspace/jenkins_app/

# Testing File Index.html
html-validator --file index.html --verbose || exit 1

# Hentikan dan hapus container lama (jika ada)
docker stop webapp || true
docker rm webapp || true

# Build ulang Docker image
docker build -t jenkins-apps .

# Jalankan container baru
docker run -d -p 3002:80 --name jenkinsapss jenkins-apps

# Bersihkan image lama yang tidak digunakan
docker image prune -f

# Buat konfigurasi Nginx otomatis
echo "server {
    listen 80;
    server_name 192.168.1.235; 

    location / {
        proxy_pass http://127.0.0.1:3002;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}" | sudo tee /etc/nginx/sites-available/jenkinsapps > /dev/null

# Aktifkan konfigurasi reverse proxy
sudo ln -sf /etc/nginx/sites-available/jenkinsapps /etc/nginx/sites-enabled/

# Tes konfigurasi Nginx
sudo nginx -t

# Restart Nginx supaya konfigurasi baru diterapkan
sudo systemctl restart nginx
