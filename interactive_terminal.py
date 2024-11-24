from flask import Flask, render_template
from flask_socketio import SocketIO
import os
import pty

app = Flask(__name__)
app.config['SECRET_KEY'] = 'supersecret!'
socketio = SocketIO(app, cors_allowed_origins="*")

master_fd = None  # File descriptor for the terminal

@app.route('/')
def index():
    return render_template('terminal.html')

@socketio.on('connect')
def connect():
    global master_fd
    try:
        # Open a pseudo-terminal
        master_fd, slave_fd = pty.openpty()
        pid = os.fork()
        if pid == 0:
            # Child process replaces itself with bash
            os.close(master_fd)
            os.dup2(slave_fd, 0)  # stdin
            os.dup2(slave_fd, 1)  # stdout
            os.dup2(slave_fd, 2)  # stderr
            os.execlp("bash", "bash")
        else:
            os.close(slave_fd)  # Parent process closes slave end
            socketio.start_background_task(target=read_output)
    except Exception as e:
        print(f"Error during terminal setup: {e}")
        socketio.emit('output', f"Server error: {e}")

def read_output():
    """Continuously read from the pseudo-terminal and send data to the frontend."""
    global master_fd
    while True:
        try:
            data = os.read(master_fd, 1024).decode()
            socketio.emit('output', data)
        except Exception as e:
            print(f"Error reading output: {e}")
            break

@socketio.on('input')
def handle_input(data):
    """Write user input to the pseudo-terminal."""
    global master_fd
    try:
        os.write(master_fd, data.encode())
    except Exception as e:
        print(f"Error writing input: {e}")

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)
