from flask import Flask, request, jsonify
import os
import subprocess
import json

app = Flask(__name__)

CREDENTIALS_FILE = "/data/credentials.json"
USER_SESSIONS = {}
BASE_PORT = 9000  # Starting port for user terminals

# Initialize credentials if not present
if not os.path.exists(CREDENTIALS_FILE):
    with open(CREDENTIALS_FILE, "w") as file:
        json.dump({"admin": "password"}, file)

def load_credentials():
    with open(CREDENTIALS_FILE, "r") as file:
        return json.load(file)

def save_credentials(credentials):
    with open(CREDENTIALS_FILE, "w") as file:
        json.dump(credentials, file)

def find_available_port():
    global BASE_PORT
    BASE_PORT += 1
    return BASE_PORT

def start_terminal(username):
    port = find_available_port()
    process = subprocess.Popen(["gotty", "--port", str(port), "--permit-write", "/bin/bash"])
    USER_SESSIONS[username] = {"port": port, "process": process}
    return port

@app.route("/login", methods=["POST"])
def login():
    data = request.json
    credentials = load_credentials()
    if data["username"] in credentials and data["password"] == credentials[data["username"]]:
        if data["username"] not in USER_SESSIONS:
            port = start_terminal(data["username"])
        else:
            port = USER_SESSIONS[data["username"]]["port"]
        return jsonify({"message": "Login successful", "port": port}), 200
    return jsonify({"message": "Invalid credentials"}), 401

@app.route("/change-password", methods=["POST"])
def change_password():
    data = request.json
    credentials = load_credentials()
    if data["username"] in credentials and data["current_password"] == credentials[data["username"]]:
        credentials[data["username"]] = data["new_password"]
        save_credentials(credentials)
        return jsonify({"message": "Password updated successfully"}), 200
    return jsonify({"message": "Current password is incorrect"}), 401

@app.route("/logout", methods=["POST"])
def logout():
    data = request.json
    if data["username"] in USER_SESSIONS:
        USER_SESSIONS[data["username"]]["process"].terminate()
        del USER_SESSIONS[data["username"]]
        return jsonify({"message": "Logout successful"}), 200
    return jsonify({"message": "No active session"}), 404

@app.route("/", methods=["GET"])
def home():
    return """
    <h1>GoTTY Backend Service</h1>
    <p>Welcome to the GoTTY Backend. Use the following endpoints:</p>
    <ul>
        <li><code>POST /login</code>: Login with a username and password.</li>
        <li><code>POST /change-password</code>: Change a user's password.</li>
    </ul>
    """, 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
