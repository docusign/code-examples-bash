import logging

from flask import Flask, render_template_string, request
from multiprocessing import Process

HOST = 'localhost'
PORT = 8080

SUCCESS_PAGE_SOURCE = """
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<script>
        fetch('http://{{host}}:{{port}}/shutdown')
        setTimeout(function () { window.close();}, 5000);
    </script>
</head>

<body>
Ok. You may close this tab and return to the shell. This window closes automatically in five seconds.

</body>
</html>
"""

ERROR_PAGE_SOURCE = """
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="utf-8">
	<title></title>
</head>

<body>
Bad request.

</body>
</html>
"""

app = Flask(__name__)
app.env = "development"
logging.getLogger('werkzeug').disabled = True
server = Process(target=app.run, args=(HOST, PORT,))


def run_server():
    server.run()


def shutdown_server():
    func = request.environ.get('werkzeug.server.shutdown')
    if func is None:
        raise RuntimeError('Not running with the Werkzeug Server')
    func()


@app.route('/shutdown')
def shutdown():
    shutdown_server()
    return 'Server shutting down...'


@app.route('/authorization-code/callback', methods=["GET"])
def result_page():
    if request.args.get("code"):
        return render_template_string(SUCCESS_PAGE_SOURCE, host=HOST, port=PORT)
    else:
        return render_template_string(ERROR_PAGE_SOURCE)
