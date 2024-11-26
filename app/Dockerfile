# Use the Python 3.9 image
FROM python:3.9

# Set the working directory
WORKDIR /app

# Copy the backend script into the container
COPY backend.py /app/backend.py

# Install any dependencies (if required)
# Add your dependencies here, e.g., Flask
RUN pip install flask

# Expose the backend port
EXPOSE 5000

# Run the backend script
CMD ["python", "/app/backend.py"]
