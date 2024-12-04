
FROM ubuntu:latest

# Set environment variables
ENV LANG=C.UTF-8

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    tar \
    bash \
    build-essential \
    ca-certificates \
    sudo && \
    apt-get clean

# Install GoTTY pre-compiled binary
RUN curl -sSL -O https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty_linux_amd64.tar.gz && \
    mv gotty /usr/local/bin/ && \
    chmod +x /usr/local/bin/gotty && \
    rm -f gotty_linux_amd64.tar.gz

# Install gosu for user switching
RUN curl -sSL -o /usr/local/bin/gosu https://github.com/tianon/gosu/releases/download/1.14/gosu-amd64 && \
    chmod +x /usr/local/bin/gosu && \
    echo "Gosu installed at $(which gosu)" && \
    ls -l /usr/local/bin/gosu

# Expose the port for GoTTY
EXPOSE 8090

# Add a user creation and switch logic
# Default entrypoint that creates the user if it doesn't exist and switches to it
ENTRYPOINT ["/bin/bash", "-c", " \
    if [ -n \"$GOTTY_USER\" ]; then \
        useradd -m -s /bin/bash \"$GOTTY_USER\" && \
        echo \"$GOTTY_USER ALL=(ALL) NOPASSWD:ALL\" > /etc/sudoers.d/$GOTTY_USER; \
    fi && \
    echo \"Starting GoTTY for user $GOTTY_USER\" && \
    exec gosu $GOTTY_USER /usr/local/bin/gotty --permit-write --reconnect /bin/bash"]

# Required to run as root for the user creation
USER root