from flask import Flask, request, jsonify, send_from_directory
import os
import subprocess
import json
import socket
import signal
import logging
import time

app = Flask(__name__)

# Setup basic logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

# Reap zombie processes automatically
signal.signal(signal.SIGCHLD, signal.SIG_IGN)

# Serve the login page at the root URL
@app.route("/", methods=["GET"])
def serve_login_page():
    return send_from_directory("/app/frontend", "login-page.html")

# Path to credentials file
CREDENTIALS_FILE = "/data/credentials.json"

# Utility function to load credentials
def load_credentials():
    if not os.path.exists(CREDENTIALS_FILE):
        logging.info("Credentials file not found. Creating with default credentials.")
        default_credentials = {"admin": "password"}
        save_credentials(default_credentials)
    with open(CREDENTIALS_FILE, "r") as f:
        return json.load(f)

# Utility function to save credentials
def save_credentials(credentials):
    os.makedirs(os.path.dirname(CREDENTIALS_FILE), exist_ok=True)
    with open(CREDENTIALS_FILE, "w") as f:
        json.dump(credentials, f, indent=4)

# Utility function to find a free port
def find_free_port():
    for port in range(41000, 42000):
        with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
            if s.connect_ex(("0.0.0.0", port)) != 0:
                return port
    raise Exception("No free ports available")

# Function to start the GoTTY terminal for a user
def start_terminal(username):
    """
    Starts a GoTTY terminal for a specific user.

    Args:
        username (str): The username for whom the terminal is started.

    Returns:
        int: The port on which the terminal is running.

    Raises:
        Exception: If the terminal fails to start.
    """
    port = find_free_port()
    try:
        command = [
            "gotty",
            "--address", "0.0.0.0",  # Bind to all IPv4 addresses
            "--port", str(port),     # Assign the dynamic port
            "--permit-write",        # Allow write access in the terminal
            "/bin/bash"              # Command to execute in the terminal
        ]

        logging.info(f"Starting gotty on port {port} with command: {' '.join(command)}")

        # Start the GoTTY process
        process = subprocess.Popen(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        # Add a brief delay to allow process initialization
        time.sleep(1)

        # Check if the process is running
        if process.poll() is not None:
            stdout, stderr = process.communicate()
            logging.error(f"Gotty failed to start. Stdout: {stdout.decode()}, Stderr: {stderr.decode()}")
            raise Exception(f"Failed to start GoTTY on port {port}. See logs for details.")

        logging.info(f"Started GoTTY terminal for user '{username}' on port {port}.")
        return port

    except Exception as e:
        logging.error(f"Failed to start terminal for user '{username}': {e}")
        raise




# Login API
@app.route("/login", methods=["POST"])
def login():
    try:
        data = request.json
        credentials = load_credentials()
        username = data.get("username")
        password = data.get("password")

        if username in credentials and credentials[username] == password:
            port = start_terminal(username)
            return jsonify({"message": "Login successful", "port": port}), 200
        return jsonify({"message": "Invalid credentials"}), 401
    except Exception as e:
        logging.error(f"Error in login: {e}")
        return jsonify({"message": "Internal server error"}), 500

# Change Password API
@app.route("/change-password", methods=["POST"])
def change_password():
    try:
        data = request.json
        credentials = load_credentials()
        username = data.get("username")
        current_password = data.get("current_password")
        new_password = data.get("new_password")

        if username in credentials and credentials[username] == current_password:
            credentials[username] = new_password
            save_credentials(credentials)
            logging.info(f"Password updated for user '{username}'.")
            return jsonify({"message": "Password updated successfully"}), 200
        return jsonify({"message": "Invalid username or password"}), 401
    except Exception as e:
        logging.error(f"Error in change-password: {e}")
        return jsonify({"message": "Internal server error"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
