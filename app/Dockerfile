# Use the Python 3.9 image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the backend script into the container
COPY backend.py /app/backend.py

# Copy the frontend files
COPY frontend /app/frontend


# Install Flask
RUN pip install flask

# Install GoTTY
RUN apt-get update && apt-get install -y curl tar && \
    curl -sSL -O https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty_linux_amd64.tar.gz && \
    mv gotty /usr/local/bin/ && \
    chmod +x /usr/local/bin/gotty && \
    rm -f gotty_linux_amd64.tar.gz

# Expose the backend port
EXPOSE 5000

# Run the backend script
CMD ["python", "/app/backend.py"]

