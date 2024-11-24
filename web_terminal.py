from flask import Flask
from flask_socketio import SocketIO
import subprocess

app = Flask(__name__)
app.config['SECRET_KEY'] = 'secret!'
socketio = SocketIO(app)

@app.route('/')
def index():
    return '''
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <title>Python-Based Web Terminal</title>
            <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.3.2/socket.io.js"></script>
        </head>
        <body>
            <h1>Python-Based Web Terminal</h1>
            <textarea id="output" rows="20" cols="100" readonly></textarea><br>
            <input type="text" id="command" placeholder="Enter command here..." size="100"/>
            <button onclick="sendCommand()">Execute</button>
            <script>
                const socket = io();

                function sendCommand() {
                    const command = document.getElementById('command').value;
                    socket.emit('execute', command);
                    document.getElementById('command').value = '';
                }

                socket.on('response', function(data) {
                    const output = document.getElementById('output');
                    output.value += data + '\n';
                });
            </script>
        </body>
        </html>
    '''

@socketio.on('execute')
def execute_command(command):
    try:
        output = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
        socketio.emit('response', output.decode())
    except subprocess.CalledProcessError as e:
        socketio.emit('response', e.output.decode())

if __name__ == '__main__':
    socketio.run(app, host='0.0.0.0', port=5000)