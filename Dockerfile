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


# Pull base image
FROM ubuntu:20.04

# Set glibc version and other ENVs
ENV GLIBC_VERSION=2.26 \
    LANG=C.UTF-8

# Install necessary build dependencies and glibc
RUN set -ex && \
    # Install required dependencies
    apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    wget \
    gcc \
    libc6-dev \
    make \
    && \
    # Download and install glibc
    curl -sSL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc_${GLIBC_VERSION}-1_amd64.deb -o /tmp/glibc.deb && \
    curl -sSL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin_${GLIBC_VERSION}-1_amd64.deb -o /tmp/glibc-bin.deb && \
    curl -sSL https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-i18n_${GLIBC_VERSION}-1_all.deb -o /tmp/glibc-i18n.deb && \
    dpkg -i /tmp/*.deb && \
    rm -f /tmp/*.deb && \
    # Configure locale to UTF-8
    locale-gen C.UTF-8 && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    # Clean up unnecessary packages
    apt-get purge -y gcc make libc6-dev && \
    apt-get autoremove -y && \
    apt-get clean

# Install GoTTY (web-based terminal)
RUN curl -sSL -O https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvzf gotty_linux_amd64.tar.gz && \
    mv gotty /usr/local/bin/ && \
    rm -f gotty_linux_amd64.tar.gz

# Install additional dependencies (jq)
RUN apt-get update && apt-get install -y jq && apt-get clean

# Set standard start command for GoTTY
CMD ["/usr/local/bin/gotty", "--permit-write", "--reconnect", "/bin/bash"]

