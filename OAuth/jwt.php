<?php

require 'utils.php';

$api_version = "$argv[1]";

$timestamp = date_timestamp_get(date_create());
$userID    = $IMPERSONATION_USER_GUID;
$signature = '';

$header = encodeBase64URL(
  json_encode([
    'typ' => 'JWT',
    'alg' => 'RS256'
  ])
);

if($api_version == "eSignature"):
  $body = encodeBase64URL(
    json_encode([
      'iss'   => $INTEGRATION_KEY_JWT,
      'sub'   => $userID,
      'iat'   => $timestamp,
      'exp'   => $timestamp + 3600,
      'aud'   => 'account-d.docusign.com',
      'scope' => 'signature impersonation'
    ])
  );
elseif($api_version == "Rooms"):
  $body = encodeBase64URL(
    json_encode([
      'iss'   => $INTEGRATION_KEY_JWT,
      'sub'   => $userID,
      'iat'   => $timestamp,
      'exp'   => $timestamp + 3600,
      'aud'   => 'account-d.docusign.com',
      'scope' => 'signature impersonation dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms'
    ])
  );
endif;

$privateKey = file_get_contents("config/private.key");
openssl_sign($header . '.' . $body, $signature, $privateKey, 'sha256');
echo "\nGetting a JWT access token...\n";

$jwt = $header . '.' . $body . '.' . encodeBase64URL($signature);



$response = http($authorizationEndpoint . 'token', [
  'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
  'assertion'  => $jwt
], false, true);


//TODO This SHOULD be presented on requires_consent for first time validation or if consent has been revoked

if(isset($response->error)){
if($response->error == "consent_required"){

$authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query([
  'scope'         => 'signature impersonation dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms',
  'redirect_uri'  => $redirectURI,
  'client_id'     => $INTEGRATION_KEY_JWT,
  'state'         => $state,
  'response_type' => 'code'
]);

echo "\nOpen the following URL in a browser to continue:\n" . $authorizationURL . "\n";
// Windows fix: https://stackoverflow.com/a/1327444/2226328
if(stripos(PHP_OS, 'WIN') === 0){

  shell_exec('start "" "'.$authorizationURL.'"');

}

else {

  shell_exec("xdg-open " . $authorizationURL);
}


$auth = startHttpServer($socket);

if ($auth['state'] != $state) {
  echo "\nWrong 'state' parameter returned\n";
  exit(2);
}

$code = $auth['code'];
echo "\nGetting an access token...\n";


$privateKey = file_get_contents("config/private.key");
openssl_sign($header . '.' . $body, $signature, $privateKey, 'sha256');
echo "\nGetting a JWT access token...\n";

$jwt = $header . '.' . $body . '.' . encodeBase64URL($signature);



$response = http($authorizationEndpoint . 'token', [
  'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
  'assertion'  => $jwt
], false, true);


if (!isset($response->access_token)) {
  echo "\nError fetching access token\n";
  exit(2);
}

$accessToken = $response->access_token;


}

}

if(!$response->access_token){
  var_dump($response);
}


$accessToken = $response->access_token;
file_put_contents($outputFile, $accessToken);
echo "\nAccess token has been written to " . $outputFile . "\n\n";

// Retrieve the API Account ID for subsequent API calls
$userInfo = http($authorizationEndpoint . 'userinfo', false, [
  'Authorization: Bearer ' . $accessToken
]);


$APIAccountId = $userInfo->accounts[0]->account_id;
file_put_contents('config/API_ACCOUNT_ID', $APIAccountId);

?>
