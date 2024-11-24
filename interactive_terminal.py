from flask import Flask, render_template, session
from flask_socketio import SocketIO, disconnect
import os
import pty
import traceback

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, cors_allowed_origins="*", manage_session=True)

# Global variables for terminal
terminals = {}
sessions = {}

@app.route('/')
def index():
    return render_template('terminal.html')

@socketio.on('connect')
def on_connect():
    global terminals, sessions
    session_id = session.sid
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
            terminals[session_id] = master_fd
            sessions[session_id] = True
            print(f"Client {session_id} connected")
            socketio.start_background_task(target=read_output, session_id=session_id)
    except Exception as e:
        print(f"Error during connection setup for session {session_id}: {e}")
        traceback.print_exc()
        disconnect()

@socketio.on('disconnect')
def on_disconnect():
    session_id = session.sid
    if session_id in terminals:
        os.close(terminals[session_id])
        del terminals[session_id]
        del sessions[session_id]
    print(f"Client {session_id} disconnected")

@socketio.on('input')
def handle_input(data):
    session_id = session.sid
    if session_id in terminals:
        os.write(terminals[session_id], data.encode())
    else:
        print(f"Invalid session {session_id}, ignoring input")

def read_output(session_id):
    while sessions.get(session_id):
        try:
            data = os.read(terminals[session_id], 1024).decode()
            socketio.emit('output', data, to=session_id)
        except Exception as e:
            print(f"Error reading from terminal for session {session_id}: {e}")
            break

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)