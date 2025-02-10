# Gunakan image Nginx sebagai base
FROM nginx:latest

# Hapus konfigurasi default Nginx
RUN rm -rf /usr/share/nginx/html/*

# Copy file website ke dalam container
COPY . /usr/share/nginx/html

# Expose port 3002 agar bisa diakses dari luar
EXPOSE 3002

# Jalankan Nginx di foreground agar container tetap hidup
CMD ["nginx", "-g", "daemon off;"]
