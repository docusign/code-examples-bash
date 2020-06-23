<?php

$PORT                  = '8080';
$IP                    = 'localhost';

$outputFile            = 'config/ds_access_token.txt';
$state                 = bin2hex(random_bytes(5));

$clientID              = getenv("INTEGRATION_KEY");
$clientSecret          = getenv("INTEGRATION_SECRET");
$authorizationEndpoint = 'https://account-d.docusign.com/oauth/';

$socket                =  'tcp://' . $IP . ':' . $PORT;
$redirectURI           = 'http://' . $IP . ':' . $PORT . '/authorization-code/callback';

function startHttpServer ($socket) {
  $responseOk = "HTTP/1.0 200 OK\r\n"
    . "Content-Type: text/plain\r\n\r\n"
    . "Ok. You may close this tab and return to the shell.\r\n";

  $responseErr = "HTTP/1.0 400 Bad Request\r\n"
    . "Content-Type: text/plain\r\n\r\n"
    . "Bad Request\r\n";

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
      $parts = parse_url($url);

      if (isset($parts['path']) && $parts['path'] == '/authorization-code/callback' && isset($parts['query'])) {
        parse_str($parts['query'], $query);

        if (isset($query['code']) && isset($query['state'])) {
          fwrite($sock, $responseOk);
          fclose($sock);
          return $query;
        }
      }
    }

    fwrite($sock, $responseErr);
    fclose($sock);
  } while (true);
}

function http ($url, $params = false, $headers = false, $post = false) {
  $ch = curl_init($url);

  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  curl_setopt($ch, CURLINFO_HEADER_OUT, true);
  curl_setopt($ch, CURLOPT_VERBOSE, 1);

  if ($post) curl_setopt($ch, CURLOPT_POST, 1);

  curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
  curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);

  if ($params) {
    curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($params));
  }

  if ($headers) {
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
  }
  
  $resp = curl_exec($ch);
  return json_decode($resp);
}

function encodeBase64URL ($data) {
  return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
}

?>
