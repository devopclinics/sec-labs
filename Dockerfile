# Base Image
FROM ubuntu:20.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && \
    apt-get install -y nginx shellinabox && \
    apt-get clean

# Create directories for certificates inside the container
RUN mkdir -p /home/dev/sec-labs/cert

# Copy Nginx configuration and certificates into the container
COPY nginx.conf /etc/nginx/nginx.conf
COPY cert/certificate.pem /home/dev/sec-labs/cert/certificate.pem
COPY cert/certificate.key /home/dev/sec-labs/cert/certificate.key

# Ensure correct permissions for certificates
RUN chmod 644 /home/dev/sec-labs/cert/certificate.pem && \
    chmod 600 /home/dev/sec-labs/cert/certificate.key

# Expose Nginx and Shellinabox ports
EXPOSE 80 443 4200

# Start Nginx and Shellinabox
CMD ["/bin/bash", "-c", "service nginx start && shellinaboxd --no-beep --disable-peer-check --cert=/home/dev/sec-labs/cert/certificate.pem --key=/home/dev/sec-labs/cert/certificate.key -s /:root:root:/root:/bin/bash"]
