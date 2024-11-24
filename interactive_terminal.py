from flask import Flask, render_template
from flask_socketio import SocketIO
import os
import pty
import select

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, cors_allowed_origins="*")

@app.route('/')
def index():
    return render_template('terminal.html')

@socketio.on('input')
def handle_input(data):
    try:
        os.write(master_fd, data.encode())
    except Exception as e:
        print(f"Error writing to PTY: {e}")

@socketio.on('connect')
def connect():
    global master_fd, slave_fd, child_pid
    try:
        master_fd, slave_fd = pty.openpty()
        child_pid = os.fork()
        if child_pid == 0:
            # Child process: Start bash
            os.close(master_fd)
            os.dup2(slave_fd, 0)  # stdin
            os.dup2(slave_fd, 1)  # stdout
            os.dup2(slave_fd, 2)  # stderr
            os.execlp("bash", "bash")
        else:
            # Parent process: Close slave end and forward output
            os.close(slave_fd)
            socketio.start_background_task(target=read_and_forward_output, fd=master_fd)
    except Exception as e:
        print(f"Error during PTY initialization: {e}")
        socketio.emit('output', f"Server error: {e}")

def read_and_forward_output(fd):
    try:
        while True:
            data = os.read(fd, 1024).decode()
            socketio.emit('output', data)
    except Exception as e:
        print(f"Error reading from PTY: {e}")

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)
