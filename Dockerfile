# Use the latest Ubuntu image
FROM ubuntu:latest

# Set environment variables
ENV LANG=C.UTF-8 TERM=xterm

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
    tar -xvf gotty_linux_amd64.tar.gz && mv gotty /usr/local/bin/ && chmod +x /usr/local/bin/gotty && \
    rm -f gotty_linux_amd64.tar.gz

# Create a directory for user data
RUN mkdir -p /user_sessions

# Expose the port for GoTTY
EXPOSE 8080

# Set standard start command for GoTTY with authentication and persistent session
CMD ["/usr/local/bin/gotty", "--permit-write", "--credential", "user:password", "--reconnect", "/bin/bash"]
