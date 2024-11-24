from flask import Flask, render_template
from flask_socketio import SocketIO, emit
import os
import pty
import select

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app, cors_allowed_origins="*")

terminals = {}
sessions = {}

@app.route('/')
def index():
    return render_template('terminal.html')

@socketio.on('connect')
def on_connect():
    sid = request.sid
    try:
        master_fd, slave_fd = pty.openpty()
        pid = os.fork()
        if pid == 0:  # Child process
            os.close(master_fd)
            os.dup2(slave_fd, 0)
            os.dup2(slave_fd, 1)
            os.dup2(slave_fd, 2)
            os.execlp("bash", "bash")
        else:  # Parent process
            os.close(slave_fd)
            terminals[sid] = master_fd
            print(f"Terminal session {sid} started.")
            socketio.start_background_task(target=read_terminal_output, sid=sid)
    except Exception as e:
        print(f"Error starting terminal session {sid}: {e}")

@socketio.on('disconnect')
def on_disconnect():
    sid = request.sid
    if sid in terminals:
        os.close(terminals[sid])
        del terminals[sid]
        print(f"Terminal session {sid} ended.")

@socketio.on('input')
def on_input(data):
    sid = request.sid
    if sid in terminals:
        os.write(terminals[sid], data.encode())

def read_terminal_output(sid):
    while sid in terminals:
        master_fd = terminals[sid]
        try:
            r, _, _ = select.select([master_fd], [], [], 0.1)
            if r:
                output = os.read(master_fd, 1024).decode()
                socketio.emit('output', output, to=sid)
        except OSError:
            break

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)
