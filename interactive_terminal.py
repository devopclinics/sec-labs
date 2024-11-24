from flask import Flask, render_template
from flask_socketio import SocketIO
import os
import pty
import select

app = Flask(__name__)
app.config['SECRET_KEY'] = 'supersecret!'
socketio = SocketIO(app, cors_allowed_origins="*")

master_fd = None  # Master file descriptor for the terminal

@app.route('/')
def index():
    return render_template('terminal.html')

@socketio.on('connect')
def on_connect():
    global master_fd, slave_fd
    print("Client connected")
    try:
        master_fd, slave_fd = pty.openpty()
        pid = os.fork()
        if pid == 0:
            # Child process to run bash
            os.close(master_fd)
            os.dup2(slave_fd, 0)  # stdin
            os.dup2(slave_fd, 1)  # stdout
            os.dup2(slave_fd, 2)  # stderr
            os.execlp("bash", "bash")
        else:
            os.close(slave_fd)  # Parent process closes slave end
            socketio.start_background_task(target=read_and_forward_output, fd=master_fd)
    except Exception as e:
        print(f"Error during terminal setup: {e}")
        socketio.emit('output', f"Error: {e}")

@socketio.on('disconnect')
def on_disconnect():
    print("Client disconnected")

def read_and_forward_output(fd):
    """Continuously read from the pseudo-terminal and send data to the frontend."""
    try:
        while True:
            data = os.read(fd, 1024).decode()
            socketio.emit('output', data)
    except Exception as e:
        print(f"Error reading output: {e}")

@socketio.on('input')
def on_input(data):
    """Write user input to the pseudo-terminal."""
    global master_fd
    try:
        os.write(master_fd, data.encode())
    except Exception as e:
        print(f"Error writing input: {e}")

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)
