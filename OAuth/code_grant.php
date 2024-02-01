<?php

require 'utils.php';

$outputFile = "config/ds_access_token.txt";
$apiAccountIdFile = 'config/API_ACCOUNT_ID';
if (!file_exists($outputFile)) {
    $outputFile = "../config/ds_access_token.txt";
    $apiAccountIdFile = '../config/API_ACCOUNT_ID';
}

$api_version = "$argv[1]";

if($api_version == "eSignature" || $api_version == "idEvidence") :
    $scope = 'signature';
elseif($api_version == "Rooms") :
    $scope = 'dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms';
elseif($api_version == "Click") :
    $scope = 'click.manage click.send';
elseif($api_version == "Monitor") :
    echo "Auth Code Grant is not supported for the Monitor API.";
    $scope = "signature impersonation";
elseif($api_version == "Admin") :
    $scope = 'signature organization_read group_read permission_read user_read user_write account_read domain_read identity_provider_read user_data_redact asset_group_account_read asset_group_account_clone_write asset_group_account_clone_read';
elseif($api_version == "Notary") :
    $scope = "signature organization_read notary_read notary_write";
elseif($api_version == "WebForms") :
    $scope = "signature webforms_manage webforms_read webforms_instance_read webforms_instance_write";
elseif($api_version == "Maestro") :
    $scope = "signature aow_manage";
endif;

$authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query(
    [
      'redirect_uri'  => $redirectURI,
      'scope'         => $scope,
      'client_id'     => $clientID,
      'state'         => $state,
      'response_type' => 'code'
    ]
);

echo "\nOpen the following URL in a browser to continue:\n" . $authorizationURL . "\n";


// Windows fix: https://stackoverflow.com/a/1327444/2226328
if (stripos(PHP_OS, 'WIN') === 0) {
    shell_exec('start "" "'.$authorizationURL.'"');
} else {
    shell_exec("xdg-open " . $authorizationURL);
}

$auth = startHttpServer($socket);

if ($auth['state'] != $state) {
    echo "\nWrong 'state' parameter returned\n";
    exit(2);
}

$code = $auth['code'];
echo "\nGetting an access token...\n";

$response = http(
    $authorizationEndpoint . 'token', [
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

$userInfo = http($authorizationEndpoint . 'userinfo', false,
    [
        'Authorization: Bearer ' . $accessToken
    ]
);

if ($TARGET_ACCOUNT_ID != "{TARGET_ACCOUNT_ID}") {
    $targetAccountFound = false;
    foreach ($userInfo->accounts as $account_info) {
        if ($account_info->account_id == $TARGET_ACCOUNT_ID) {
            $APIAccountId = $account_info->account_id;
            $targetAccountFound = true;
            break;
        }
    }
    if (! $targetAccountFound) {
        throw new Exception("Targeted Account with Id " . $TARGET_ACCOUNT_ID . " not found.");
    }
} else {
    foreach ($userInfo->accounts as $account_info) {
        if ($account_info->is_default) {
            $APIAccountId = $account_info->account_id;
            break;
        }
    }
}

file_put_contents($apiAccountIdFile, $APIAccountId);
echo "Account id: $APIAccountId\n";
echo "Account id has been written to config/API_ACCOUNT_ID file...\n\n";
?>
