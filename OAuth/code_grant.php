<?php

require 'utils.php';

$api_version = "$argv[1]";

if($api_version == "eSignature"):
  $authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query([
    'redirect_uri'  => $redirectURI,
    'scope'         => 'signature impersonation',
    'client_id'     => $clientID,
    'state'         => $state,
    'response_type' => 'code'
  ]);
elseif($api_version == "Rooms"):
  $authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query([
    'redirect_uri'  => $redirectURI,
    'scope'         => 'signature impersonation dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms',
    'client_id'     => $clientID,
    'state'         => $state,
    'response_type' => 'code'
  ]);
  elseif($api_version == "Click"):
    $authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query([
      'redirect_uri'  => $redirectURI,
      'scope'         => 'signature click.manage',
      'client_id'     => $clientID,
      'state'         => $state,
      'response_type' => 'code'
    ]);
endif;

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

$userInfo = http($authorizationEndpoint . 'userinfo', false, [
  'Authorization: Bearer ' . $accessToken
]);
  // impersonation user guid
  // var_dump($userInfo->sub);
  $APIAccountId = $userInfo->accounts[0]->account_id;
  file_put_contents('config/API_ACCOUNT_ID', $APIAccountId);
?>
