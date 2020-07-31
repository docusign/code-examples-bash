<?php

require 'utils.php';


$timestamp = date_timestamp_get(date_create());
$userID    = $JWT_IMPERSONATION_GUID;
$signature = '';

$header = encodeBase64URL(
  json_encode([
    'typ' => 'JWT',
    'alg' => 'RS256'
  ])
);

$body = encodeBase64URL(
  json_encode([
    'iss'   => $JWT_INTEGRATION_KEY,
    'sub'   => $userID,
    'iat'   => $timestamp,
    'exp'   => $timestamp + 3000,
    'aud'   => 'account-d.docusign.com',
    'scope' => 'signature impersonation'
  ])
);

$privateKey = file_get_contents("config/private.key");
openssl_sign($header . '.' . $body, $signature, $privateKey, 'sha256');
echo "\nGetting a JWT access token...\n";

$jwt = $header . '.' . $body . '.' . encodeBase64URL($signature);


echo $JWT_INTEGRATION_KEY;
echo $userID;



$response = http($authorizationEndpoint . 'token', [
  'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
  'assertion'  => $jwt
], false, true);


//TODO THIS SHOULD be presented on requires_consent only


if($response->body == "consent_required"){

// $authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query([
//   'scope'         => 'signature impersonation',
//   'redirect_uri'  => $redirectURI,
//   'client_id'     => $JWT_INTEGRATION_KEY,
//   'state'         => $state,
//   'response_type' => 'code'
// ]);

// echo "\nOpen the following URL in a browser to continue:\n" . $authorizationURL . "\n";


// $auth = startHttpServer($socket);

// if ($auth['state'] != $state) {
//   echo "\nWrong 'state' parameter returned\n";
//   exit(2);
// }

// $code = $auth['code'];
// echo "\nGetting an access token...\n";

// $response = http($authorizationEndpoint . 'token', [
//     'grant_type'    => 'authorization_code',
//     'redirect_uri'  => $redirectURI,
//     'code'          => $code
//   ], [
//     'Authorization: Basic ' . base64_encode($JWT_INTEGRATION_KEY . ':' . $clientSecret),
//   ], true
// );

// if (!isset($response->access_token)) {
//   echo "\nError fetching access token\n";
//   exit(2);
// }

// $accessToken = $response->access_token;
// echo "\nGetting user info...\n";

// $userInfo = http($authorizationEndpoint . 'userinfo', false, [
//   'Authorization: Bearer ' . $accessToken
// ]);

}
if(!$response->access_token){
  var_dump($response);
}


$accessToken = $response->access_token;
file_put_contents($outputFile, $accessToken);
echo "\nAccess token has been written to " . $outputFile . "\n\n";

?>
