# Dockerfile
FROM ubuntu:latest

# Set non-interactive mode to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    build-essential \
    git \
    tmux \
    bash \
    && apt-get clean

# Install GoTTY (Web-based terminal tool)
RUN wget -O /usr/local/bin/gotty https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64 && \
    chmod +x /usr/local/bin/gotty

# Expose the web terminal on port 8080
EXPOSE 8080

# Run gotty to expose the bash terminal
CMD ["gotty", "-w", "/bin/bash"]
