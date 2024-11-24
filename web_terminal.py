from flask import Flask, render_template, request
from flask_socketio import SocketIO
import os
import subprocess

app = Flask(__name__)
socketio = SocketIO(app)

@app.route('/')
def index():
    return "<h1>Welcome to the Python-Based Web Terminal</h1>"

@socketio.on('execute')
def handle_execution(command):
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
        socketio.emit('response', output.decode())
    except subprocess.CalledProcessError as e:
        socketio.emit('response', e.output.decode())

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)