FROM ubuntu:20.04

# Install necessary tools
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    net-tools \
    curl \
    wget \
    vim \
    && apt-get clean

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22

# Entry point
CMD ["/usr/sbin/sshd", "-D"]