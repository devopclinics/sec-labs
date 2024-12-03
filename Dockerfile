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
    && apt-get clean

# Install GoTTY pre-compiled binary
RUN curl -sSL -O https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty_linux_amd64.tar.gz && \
    mv gotty /usr/local/bin/ && \
    chmod +x /usr/local/bin/gotty && \
    rm -f gotty_linux_amd64.tar.gz

# Create a non-root group and user, letting the system assign UID and GID
RUN groupadd ${GOTTY_USER} && \
    useradd -m -s /bin/bash -g ${GOTTY_USER} ${GOTTY_USER}

# Install gosu for user switching
RUN curl -sSL -o /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64 && \
    chmod +x /usr/local/bin/gosu

# Ensure the non-root user's home directory and other directories have the correct permissions
RUN mkdir -p /user_sessions && \
    chown -R ${GOTTY_USER}:${GOTTY_USER} /home/${GOTTY_USER} /user_sessions

# Expose the port for GoTTY
EXPOSE 8080

# Set the correct user for the GoTTY command
USER ${GOTTY_USER}

# Set the default command to run GoTTY, using gosu for user switching
CMD ["/usr/local/bin/gosu", "nonroot", "gotty", "--permit-write", "--reconnect", "/bin/bash"]
