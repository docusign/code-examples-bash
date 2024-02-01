<?php

$PORT           = '8080';
$IP             = 'localhost';

$state          = bin2hex(random_bytes(5));

$integrationKey = "$argv[1]";
$url            = "$argv[2]";
$instanceToken  = "$argv[3]";

$socket         =  'tcp://' . $IP . ':' . $PORT;

$responseOk = "HTTP/1.0 200 OK\r\n"
    . "Content-Type: text/html\r\n\r\n"
    . "
    <!DOCTYPE html>
    <html>
  <head>
    <meta charset=\"UTF-8\" />
  </head>

  <body>
    <div id=\"app\">
      <div id=\"webform-customer-app-area\">
        <h1 id=\"webforms-heading\">Embedded Web Form Example</h1>
        <div id=\"docusign\" class=\"webform-iframe-container\">
          <p>Web Form will render here</p>
        </div>
      </div>
    </div>
  </body>
</html>
<!--
    #ds-snippet-start:WebForms1Step6
-->
<script src=\"https://js.docusign.com/bundle.js\"></script>
<script>
async function loadWebform() {
  const { loadDocuSign } = window.DocuSign
  const docusign = await loadDocuSign('" . $integrationKey . "');

  const webFormOptions = {
    // Optional field that can prefill values in the form. This overrides the formValues field in the API request
    prefillValues: {},
    // Used with the runtime API workflow, for private webforms this is needed to render anything
    instanceToken: '" . $instanceToken . "',
    // Controls whether the progress bar is shown or not
    hideProgressBar: false,
    // These styles get passed directly to the iframe that is rendered
    iframeStyles: {
      minHeight: \"1500px\",
    },
    // Controls the auto resize behavior of the iframe
    autoResizeHeight: true,
    // These values are passed to the iframe URL as query params
    tracking: {
      \"tracking-field\": \"tracking-value\",
    },
    //These values are passed to the iframe URL as hash params
    hidden: {
      \"hidden-field\": \"hidden-value\",
    },
  };

  const webFormWidget = docusign.webforms({
    url: '" . $url . "',
    options: webFormOptions,
  });

  webFormWidget.mount(\"#docusign\");
}
loadWebform();
</script>
<!--
    #ds-snippet-end:WebForms1Step6
-->
";

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
