<?php

$PORT           = '8080';
$IP             = 'localhost';

$state          = bin2hex(random_bytes(5));

$integrationKey = "$argv[1]";
$url            = "$argv[2]";

$socket         =  'tcp://' . $IP . ':' . $PORT;

$responseOk = "HTTP/1.0 200 OK\r\n"
    . "Content-Type: text/html\r\n\r\n"
    . "
    <!--
    #ds-snippet-start:eSign44Step6
    -->
    <br />
    <h2>The document has been embedded with focused view.</h2>
    <br />

    <!DOCTYPE html>
    <html>
    <head>
        <meta charset=\"utf-8\" />
        <title>Signing</title>
        <style>
            html,
            body {
                padding: 0;
                margin: 0;
                font: 13px Helvetica, Arial, sans-serif;
            }

            .docusign-agreement {
                width: 75%;
                height: 800px;
            }
        </style>
    </head>
    <body>
        <div class=\"docusign-agreement\" id=\"agreement\"></div>
    </body>
    </html>

    <p><a>Continue</a></p>

    <script src='https://js.docusign.com/bundle.js'></script>
    <script>
        window.DocuSign.loadDocuSign('" . $integrationKey . "')
            .then((docusign) => {
                const signing = docusign.signing({
                    url: '" . $url . "',
                    displayFormat: 'focused',
                    style: {
                        /** High-level variables that mirror our existing branding APIs. Reusing the branding name here for familiarity. */
                        branding: {
                            primaryButton: {
                                /** Background color of primary button */
                                backgroundColor: '#333',
                                /** Text color of primary button */
                                color: '#fff',
                            }
                        },
                    
                        /** High-level components we allow specific overrides for */
                        signingNavigationButton: {
                            finishText: 'You have finished the document! Hooray!',
                            position: 'bottom-center'
                        }
                    }
                });
            
                signing.on('ready', (event) => {
                    console.log('UI is rendered');
                });
            
                signing.on('sessionEnd', (event) => {
                    /** The event here denotes what caused the sessionEnd to trigger, such as signing_complete, ttl_expired etc../ **/
                    console.log('sessionend', event);
                    window.close();
                });
            
                signing.mount('#agreement');
            })
            .catch((ex) => {
                // Any configuration or API limits will be caught here
            });
    </script>
    
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
