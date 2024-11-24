# FROM ubuntu:20.04

# # Install necessary tools
# RUN apt-get update && apt-get install -y \
#     openssh-server \
#     sudo \
#     net-tools \
#     curl \
#     wget \
#     vim \
#     && apt-get clean

# # Configure SSH
# RUN mkdir /var/run/sshd
# RUN echo 'root:password' | chpasswd
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# # Expose SSH port
# EXPOSE 22

# # Entry point
# CMD ["/usr/sbin/sshd", "-D"]

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive


# Install necessary tools
RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    net-tools \
    curl \
    wget \
    vim \
    python3-pip \
    && apt-get clean




# Install gotty for web-based terminal
RUN curl -Lo /usr/local/bin/gotty https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64 && \
    chmod +x /usr/local/bin/gotty

# Configure SSH
RUN mkdir /var/run/sshd
RUN echo 'root:password' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Expose SSH and Gotty ports
EXPOSE 22 80

# Entry point for SSH and Gotty
CMD ["/bin/bash", "-c", "service ssh start && gotty -w /bin/bash"]