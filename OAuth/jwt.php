<?php

require 'utils.php';

$authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query([
  'scope'         => 'signature impersonation',
  'redirect_uri'  => $redirectURI,
  'client_id'     => $clientID,
  'state'         => $state,
  'response_type' => 'code'
]);

echo "\nOpen the following URL in a browser to continue:\n" . $authorizationURL . "\n";





$auth = startHttpServer($socket);

if ($auth['state'] != $state) {
  echo "\nWrong 'state' parameter returned\n";
  exit(2);
}

$code = $auth['code'];
echo "\nGetting an access token...\n";

$response = http($authorizationEndpoint . 'token', [
    'grant_type'    => 'authorization_code',
    'redirect_uri'  => $redirectURI,
    'code'          => $code
  ], [
    'Authorization: Basic ' . base64_encode($clientID . ':' . $clientSecret),
  ], true
);

if (!isset($response->access_token)) {
  echo "\nError fetching access token\n";
  exit(2);
}

$accessToken = $response->access_token;
echo "\nGetting user info...\n";

$userInfo = http($authorizationEndpoint . 'userinfo', false, [
  'Authorization: Bearer ' . $accessToken
]);

$timestamp = date_timestamp_get(date_create());
$userID    = $userInfo->sub;
$signature = '';

$header = encodeBase64URL(
  json_encode([
    'typ' => 'JWT',
    'alg' => 'RS256'
  ])
);

$payload = encodeBase64URL(
  json_encode([
    'sub'   => $userID,
    'iss'   => $clientID,
    'iat'   => $timestamp,
    'exp'   => $timestamp + 3000,
    'aud'   => 'account-d.docusign.com',
    'scope' => 'signature impersonation'
  ])
);

$privateKey = file_get_contents("config/private.key");
openssl_sign($header . '.' . $payload, $signature, $privateKey, 'sha256');
echo "\nGetting a JWT access token...\n";

$response = http($authorizationEndpoint . 'token', [
  'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
  'assertion'  => $header . '.' . $payload . '.' . encodeBase64URL($signature)
], false, true);

if(!$response->access_token){
  var_dump($response);
}


$accessToken = $response->access_token;
file_put_contents($outputFile, $accessToken);
echo "\nAccess token has been written to " . $outputFile . "\n\n";

?>
