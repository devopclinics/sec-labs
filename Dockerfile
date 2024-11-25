# Dockerfile
FROM ubuntu:latest

# Set non-interactive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    tar \
    build-essential \
    git \
    tmux \
    bash \
    && apt-get clean

# Download and install GoTTY
RUN wget -O /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf /tmp/gotty.tar.gz -C /usr/local/bin && \
    chmod +x /usr/local/bin/gotty && \
    rm /tmp/gotty.tar.gz

# Expose the web terminal on port 8080
EXPOSE 8080

# Run gotty to expose the bash terminal
CMD ["gotty", "-w", "/bin/bash"]
