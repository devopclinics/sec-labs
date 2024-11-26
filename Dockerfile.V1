# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables
ENV LANG=C.UTF-8

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    tar \
    bash \
    build-essential \
    ca-certificates && \
    apt-get clean

# Install GoTTY pre-compiled binary
RUN curl -sSL -O https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty_linux_amd64.tar.gz && \
    mv gotty /usr/local/bin/ && \
    chmod +x /usr/local/bin/gotty && \
    rm -f gotty_linux_amd64.tar.gz

# Expose the port for GoTTY
EXPOSE 8080

# Set standard start command for GoTTY
CMD ["/usr/local/bin/gotty", "--permit-write", "--reconnect", "/bin/bash"]
