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
    ca-certificates \
    && apt-get clean

# Install GoTTY pre-compiled binary
RUN curl -sSL -O https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty_linux_amd64.tar.gz && \
    mv gotty /usr/local/bin/ && \
    chmod +x /usr/local/bin/gotty && \
    rm -f gotty_linux_amd64.tar.gz

# Create the non-root user at runtime if it doesn't exist
RUN echo "Creating user based on GOTTY_USER" && \
    groupadd ${GOTTY_USER} && \
    useradd -m -s /bin/bash -g ${GOTTY_USER} ${GOTTY_USER}

# Expose the port for GoTTY
EXPOSE 8080

# Default entrypoint: ensure the user is created dynamically based on the GOTTY_USER environment variable
CMD /bin/bash -c "if ! id -u ${GOTTY_USER} > /dev/null 2>&1; then useradd -m -s /bin/bash ${GOTTY_USER}; fi && \
    chown -R ${GOTTY_USER}:${GOTTY_USER} /user_sessions && \
    su - ${GOTTY_USER} -c 'gotty --permit-write --reconnect /bin/bash'"
