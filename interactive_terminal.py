from flask import Flask, render_template
from flask_socketio import SocketIO
import os
import pty
import subprocess
import select

app = Flask(__name__)
socketio = SocketIO(app)

@app.route('/')
def index():
    return render_template('terminal.html')

@socketio.on('input')
def handle_input(data):
    os.write(master_fd, data.encode())

@socketio.on('connect')
def connect():
    global master_fd
    global slave_fd
    master_fd, slave_fd = pty.openpty()
    pid = os.fork()
    if pid == 0:
        os.execlp("bash", "bash")
    else:
        socketio.start_background_task(target=read_and_forward_output, fd=master_fd)

def read_and_forward_output(fd):
    while True:
        data = os.read(fd, 1024).decode()
        socketio.emit('output', data)

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)
