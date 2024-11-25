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

# Dockerfile
FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && apt-get install -y \
    nginx \
    shellinabox \
    && apt-get clean

# Configure Shellinabox
RUN echo "SHELLINABOX_ARGS=\"--no-beep --disable-peer-check --localhost-only -s /:root:root:/root:/bin/bash\"" > /etc/default/shellinabox

# Expose both Nginx (port 80) and Shellinabox (port 4200)
EXPOSE 80 4200

# Start both Nginx and Shellinabox when the container runs
CMD ["/bin/bash", "-c", "service nginx start && shellinaboxd"]
