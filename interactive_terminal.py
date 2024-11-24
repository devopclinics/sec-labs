from flask import Flask, render_template
from flask_socketio import SocketIO, disconnect
import os
import pty
import traceback

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, cors_allowed_origins="*", manage_session=False)

# Global variables for terminal
terminals = {}
sessions = {}

@app.route('/')
def index():
    return render_template('terminal.html')

@socketio.on('connect')
def on_connect():
    global terminals, sessions
    sid = os.urandom(8).hex()  # Generate a unique session ID
    try:
        master_fd, slave_fd = pty.openpty()
        pid = os.fork()
        if pid == 0:
            os.close(master_fd)
            os.dup2(slave_fd, 0)
            os.dup2(slave_fd, 1)
            os.dup2(slave_fd, 2)
            os.execlp("bash", "bash")
        else:
            os.close(slave_fd)
            terminals[sid] = master_fd
            sessions[sid] = True
            print(f"Client {sid} connected")
            socketio.start_background_task(target=read_output, sid=sid)
    except Exception as e:
        print(f"Error during connection setup for session {sid}: {e}")
        traceback.print_exc()
        disconnect()

@socketio.on('disconnect')
def on_disconnect():
    sid = list(sessions.keys())[0] if sessions else None
    if sid in terminals:
        os.close(terminals[sid])
        del terminals[sid]
        del sessions[sid]
    print(f"Client {sid} disconnected")

@socketio.on('input')
def handle_input(data):
    sid = list(sessions.keys())[0] if sessions else None
    if sid in terminals:
        os.write(terminals[sid], data.encode())
    else:
        print(f"Invalid session {sid}, ignoring input")

def read_output(sid):
    while sessions.get(sid):
        try:
            data = os.read(terminals[sid], 1024).decode()
            socketio.emit('output', data)
        except Exception as e:
            print(f"Error reading from terminal for session {sid}: {e}")
            break

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)