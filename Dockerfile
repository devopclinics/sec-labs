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

# FROM ubuntu:20.04

# ENV DEBIAN_FRONTEND=noninteractive
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en
# ENV GOTTY_TAG_VER v1.0.1

# # Install necessary tools
# RUN apt-get update && apt-get install -y \
#     openssh-server \
#     sudo \
#     net-tools \
#     curl \
#     wget \
#     vim \
#     python3-pip \
#     && apt-get clean

# # Install gotty for web-based terminal
# RUN apt-get -y update && \
#     apt-get install -y curl && \
#     curl -sLk https://github.com/yudai/gotty/releases/download/${GOTTY_TAG_VER}/gotty_linux_amd64.tar.gz \
#     | tar xzC /usr/local/bin && \
#     apt-get purge --auto-remove -y curl && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# # Add startup script for Gotty
# COPY /run_gotty.sh /run_gotty.sh
# RUN chmod 744 /run_gotty.sh

# # Configure SSH
# RUN mkdir /var/run/sshd
# RUN echo 'root:password' | chpasswd
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# # Expose SSH and Gotty ports
# EXPOSE 22 80

# # Entry point for SSH and Gotty
# CMD ["/bin/bash", "/run_gotty.sh"]

# FROM ubuntu:20.04

# ENV DEBIAN_FRONTEND=noninteractive
# ENV LANG en_US.UTF-8
# ENV LANGUAGE en_US:en

# # Install necessary tools
# RUN apt-get update && apt-get install -y \
#     openssh-server \
#     sudo \
#     net-tools \
#     curl \
#     wget \
#     vim \
#     python3-pip \
#     && apt-get clean

# # Install Flask for the web-based terminal
# RUN pip3 install flask flask-socketio eventlet

# # Add the web terminal application script
# COPY web_terminal.py /web_terminal.py

# # Configure SSH
# RUN mkdir /var/run/sshd
# RUN echo 'root:password' | chpasswd
# RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# # Expose SSH and Flask ports
# EXPOSE 22 5000

# # Entry point for SSH and Flask-based terminal
# CMD ["/bin/bash", "-c", "service ssh start && python3 /web_terminal.py"]


FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

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

# Install Flask and Flask-SocketIO
RUN pip3 install flask flask-socketio eventlet

# Copy the terminal server script
COPY interactive_terminal.py /interactive_terminal.py

# Expose Flask and SSH ports
EXPOSE 22 5000

# Start the server
CMD ["/bin/bash", "-c", "service ssh start && python3 /interactive_terminal.py"]
