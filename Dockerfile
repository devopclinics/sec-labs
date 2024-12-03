# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables
ENV LANG=C.UTF-8
ENV GOTTY_USER=nonroot

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    tar \
    bash \
    build-essential \
    ca-certificates \
    sudo \
    && apt-get clean

# Install GoTTY pre-compiled binary
RUN curl -sSL -O https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty_linux_amd64.tar.gz && \
    mv gotty /usr/local/bin/ && \
    chmod +x /usr/local/bin/gotty && \
    rm -f gotty_linux_amd64.tar.gz

# Create the non-root group and user (system will assign UID/GID automatically)
RUN groupadd ${GOTTY_USER} && \
    useradd -m -s /bin/bash -g ${GOTTY_USER} ${GOTTY_USER} && \
    # Add the user to the sudo group
    usermod -aG sudo ${GOTTY_USER}

# Install gosu for user switching
RUN curl -sSL -o /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64 && \
    chmod +x /usr/local/bin/gosu

# Ensure proper permissions on directories
RUN mkdir -p /user_sessions && \
    chown -R ${GOTTY_USER}:${GOTTY_USER} /home/${GOTTY_USER} /user_sessions

# Expose the port for GoTTY
EXPOSE 8080

# Set standard start command for GoTTY, using gosu for user switching
CMD ["gosu", "${GOTTY_USER}", "gotty", "--permit-write", "--reconnect", "/bin/bash"]
