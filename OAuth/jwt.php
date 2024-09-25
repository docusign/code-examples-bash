<?php

require 'utils.php';

$api_version = "$argv[1]";

$timestamp = date_timestamp_get(date_create());
$userID    = $IMPERSONATION_USER_GUID;
$signature = '';

$header = encodeBase64URL(
    json_encode(
        [
          'typ' => 'JWT',
          'alg' => 'RS256'
        ]
    )
);

if ($api_version == "eSignature" || $api_version == "idEvidence") {
    $scope = 'signature impersonation';
} else if ($api_version == "Rooms") {
    $scope = 'signature impersonation dtr.rooms.read dtr.rooms.write dtr.documents.read dtr.documents.write dtr.profile.read dtr.profile.write dtr.company.read dtr.company.write room_forms';
} else if ($api_version == "Click") {
    $scope = 'signature click.manage click.send impersonation';
} else if ($api_version == "Monitor") {
    $scope = "signature impersonation";
} else if ($api_version == "Admin") {
    $scope = 'signature organization_read group_read permission_read user_read user_write account_read domain_read identity_provider_read impersonation user_data_redact asset_group_account_read asset_group_account_clone_write asset_group_account_clone_read organization_sub_account_read organization_sub_account_write';
} else if ($api_version == "Notary") {
    $scope = "signature organization_read notary_read notary_write";
} else if ($api_version == "WebForms") {
    $scope = "signature impersonation webforms_read webforms_instance_read webforms_instance_write";
} else if ($api_version == "Maestro") {
  $scope = "signature aow_manage";
}

$body = encodeBase64URL(
    json_encode(
        [
          'iss'   => $INTEGRATION_KEY_JWT,
          'sub'   => $userID,
          'iat'   => $timestamp,
          'exp'   => $timestamp + 3600,
          'aud'   => 'account-d.docusign.com',
          'scope' => $scope
        ]
    )
);

if (!file_exists("config/private.key")) {
    echo "Error: First create an RSA keypair on your integration key and copy the private_key into the file `config/private.key` and save it";
    echo "";
    exit(2);
}

$privateKey = file_get_contents("config/private.key");
openssl_sign($header . '.' . $body, $signature, $privateKey, 'sha256');
echo "\nGetting a JWT access token...\n";

$jwt = $header . '.' . $body . '.' . encodeBase64URL($signature);

$response = http(
    $authorizationEndpoint . 'token', [
    'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    'assertion'  => $jwt
    ], false, true
);

//TODO This SHOULD be presented on requires_consent for first time validation or if consent has been revoked

if (isset($response->error)) {
    if ($response->error == "consent_required") {

        $authorizationURL = $authorizationEndpoint . 'auth?' . http_build_query(
            [
            'scope'         => $scope,
            'redirect_uri'  => $redirectURI,
            'client_id'     => $INTEGRATION_KEY_JWT,
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

        $privateKey = file_get_contents("config/private.key");
        openssl_sign($header . '.' . $body, $signature, $privateKey, 'sha256');
        echo "\nGetting a JWT access token...\n";

        $jwt = $header . '.' . $body . '.' . encodeBase64URL($signature);

        $response = http(
            $authorizationEndpoint . 'token', [
            'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
            'assertion'  => $jwt
            ], false, true
        );

        if (!isset($response->access_token)) {
            var_dump($response);
            echo "\nError fetching access token\n";
            exit(2);
        }

        $accessToken = $response->access_token;
    }
}

if (!$response->access_token) {
    var_dump($response);
}

$accessToken = $response->access_token;
file_put_contents($outputFile, $accessToken);
echo "\nAccess token has been written to " . $outputFile . "\n\n";

// Retrieve the API Account ID for subsequent API calls
$userInfo = http(
    $authorizationEndpoint . 'userinfo', false, [
    'Authorization: Bearer ' . $accessToken
    ]
);

if ($TARGET_ACCOUNT_ID != "{TARGET_ACCOUNT_ID}") {
    $targetAccountFound = false;
    foreach ($userInfo->accounts as $account_info) {
        if ($account_info->account_id == $TARGET_ACCOUNT_ID) {
            file_put_contents('config/API_ACCOUNT_ID', $account_info->account_id);
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
            file_put_contents('config/API_ACCOUNT_ID', $account_info->account_id);
            break;
        }
    }
}
?>
