<?php

$PORT           = '8080';
$IP             = 'localhost';

$state          = bin2hex(random_bytes(5));

$triggerUrl = "$argv[1]";

$socket         =  'tcp://' . $IP . ':' . $PORT;

$responseOk = "HTTP/1.0 200 OK\r\n"
    . "Content-Type: text/html\r\n\r\n"
    . "
    <!--
    #ds-snippet-start:eSign44Step6
    -->
    <br />
    <h2>The document has been embedded using Maestro Embedded Workflow.</h2>
    <br />

    <!DOCTYPE html>
    <html>
    <head>
        <meta charset=\"utf-8\" />
        <title>Example Workflow</title>
        <style>
            html,
            body {
                padding: 0;
                margin: 0;
                font: 13px Helvetica, Arial, sans-serif;
            }
        </style>
    </head>
    <body>
    #ds-snippet-start:Maestro2Step3
        <div>
            <iframe src=$triggerUrl width=800 height=600>
            </iframe>
        </div>
    #ds-snippet-end:Maestro2Step3
    </body>
    </html>

    <p><a>Continue</a></p>

    <!--
    #ds-snippet-end:eSign44Step6
    -->";

ini_set('default_socket_timeout', 60 * 5);
$server = stream_socket_server($socket, $errno, $errstr);
if (!$server) {
    Log::err('Error starting HTTP server');
    return false;
}
do {
    $sock = stream_socket_accept($server);
    if (!$sock) {
        Log::err('Error accepting socket connection');
        exit(1);
    }
    $contentLength = 0;
    $headers       = [];
    $body          = null;
    while (false !== ($line = trim(fgets($sock)))) {
        if ($line === '') break;
        $regex = '#^Content-Length:\s*([[:digit:]]+)\s*$#i';
        if (preg_match($regex, $line, $matches)) {
            $contentLength = (int)$matches[1];
        }
        $headers[] = $line;
    }
    if ($contentLength > 0) {
        $body = fread($sock, $contentLength);
    }
    list($method, $url, $httpver) = explode(' ', $headers[0]);
    if ($method == 'GET') {
        fwrite($sock, $responseOk);
        fclose($sock);
        return;
    }
} while (true);

?>
