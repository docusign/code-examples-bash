<?php

require 'utils.php';

$authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query([
  'redirect_uri'  => $redirectURI,
  'scope'         => 'signature',
  'client_id'     => $clientID,
  'state'         => $state,
  'response_type' => 'code'
]);

echo "\nOpen the following URL in a browser to continue:\n" . $authorizationURL . "\n";


// on windows I cannot seem to escape the Ampersand so it throws the additional get parametrs as commads and errors the php script
// if(stripos(PHP_OS, 'WIN') === 0){

//   shell_exec("start $authorizationURL");

// }

// else {

//   shell_exec("xdg-open $authorizationURL");
// }



$auth = startHttpServer($socket);

if ($auth['state'] != $state) {
  echo "\nWrong 'state' parameter returned\n";
  exit(2);
}

$code = $auth['code'];
echo "\nGetting an access token...\n";

$response = http($authorizationEndpoint . 'token', [
    'grant_type'   => 'authorization_code',
    'redirect_uri' => $redirectURI,
    'code'         => $code
  ], [
    'Authorization: Basic ' . base64_encode($clientID . ':' .$clientSecret),
  ], true
);

if (!isset($response->access_token)) {
  echo "\nError fetching access token\n";
  exit(2);
}

$accessToken = $response->access_token;
file_put_contents($outputFile, $accessToken);
echo "\nAccess token has been written to " . $outputFile . "\n\n";

?>
