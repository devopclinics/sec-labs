# FROM ubuntu:20.04

# ENV DEBIAN_FRONTEND=noninteractive

# # Install dependencies
# RUN apt-get update && apt-get install -y \
#     openssh-server \
#     sudo \
#     python3-pip \
#     python3 \
#     net-tools \
#     curl \
#     vim \
#     locales \
#     && apt-get clean

# # Set up locale for UTF-8
# RUN locale-gen en_US.UTF-8
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV LC_ALL en_US.UTF-8

# # Install Flask and Flask-SocketIO
# RUN pip3 install flask flask-socketio eventlet psycopg2-binary

# # Copy the application files
# COPY interactive_terminal.py /interactive_terminal.py
# COPY templates /templates

# # Configure SSH
# RUN mkdir /var/run/sshd
# RUN echo 'root:password' | chpasswd
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# # Expose SSH and Flask ports
# EXPOSE 22 5000

# CMD ["/bin/bash", "-c", "service ssh start && python3 /interactive_terminal.py"]


##############################################

# Use Ubuntu as the base image
FROM ubuntu:20.04

# Set environment variables to avoid user prompts during installations
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages (Nginx and Shellinabox)
RUN apt-get update && \
    apt-get install -y nginx shellinabox && \
    apt-get clean

# Create directories for certificates (if needed)
RUN mkdir -p /home/dev/sec-labs/cert

# Copy the Nginx configuration and certificates
COPY nginx.conf /etc/nginx/nginx.conf
COPY certificate.pem /home/dev/sec-labs/cert/certificate.pem
COPY certificate.key /home/dev/sec-labs/cert/certificate.key

# Ensure correct permissions for certificates
RUN chmod 644 /home/dev/sec-labs/cert/certificate.pem && \
    chmod 600 /home/dev/sec-labs/cert/certificate.key

# Expose Nginx and Shellinabox ports
EXPOSE 80 443 4200

# Command to start both Nginx and Shellinabox
CMD ["/bin/bash", "-c", "service nginx start && shellinaboxd --no-beep --disable-peer-check --cert=/home/dev/sec-labs/cert/certificate.pem --key=/home/dev/sec-labs/cert/certificate.key -s /:root:root:/root:/bin/bash"]


