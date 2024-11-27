from flask import Flask, request, jsonify, send_from_directory
import os
import subprocess
import json

app = Flask(__name__)

# Serve the login page at the root URL
@app.route("/", methods=["GET"])
def serve_login_page():
    return send_from_directory("/app/frontend", "login-page.html")

# Simulated in-memory credentials for demo purposes
CREDENTIALS_FILE = "/data/credentials.json"

# Utility function to load credentials
def load_credentials():
    if os.path.exists(CREDENTIALS_FILE):
        with open(CREDENTIALS_FILE, "r") as f:
            return json.load(f)
    return {}

# Utility function to save credentials
def save_credentials(credentials):
    with open(CREDENTIALS_FILE, "w") as f:
        json.dump(credentials, f)

# Login API
@app.route("/login", methods=["POST"])
def login():
    data = request.json
    credentials = load_credentials()
    username = data.get("username")
    password = data.get("password")

    if username in credentials and credentials[username] == password:
        port = start_terminal(username)
        return jsonify({"message": "Login successful", "port": port}), 200
    return jsonify({"message": "Invalid credentials"}), 401

# Change Password API
@app.route("/change-password", methods=["POST"])
def change_password():
    data = request.json
    credentials = load_credentials()
    username = data.get("username")
    current_password = data.get("current_password")
    new_password = data.get("new_password")

    if username in credentials and credentials[username] == current_password:
        credentials[username] = new_password
        save_credentials(credentials)
        return jsonify({"message": "Password updated successfully"}), 200
    return jsonify({"message": "Invalid username or password"}), 401

# Start GoTTY Terminal for a User
def start_terminal(username):
    port = 9000 + hash(username) % 1000
    process = subprocess.Popen(["gotty", "--port", str(port), "--permit-write", "/bin/bash"])
    return port

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
