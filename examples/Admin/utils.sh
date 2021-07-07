#!/bin/bash
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

if ! [ -f 'config/ORGANIZATION_ID' ]; then
    accessToken=$(cat config/ds_access_token.txt)
    response=$(mktemp /tmp/response-orgid.XXXXXX)

    curl --header "Authorization: Bearer ${accessToken}" \
    --header "Content-Type: application/json" \
    --request GET https://api-d.docusign.net/management/v2/organizations \
    --output $response

    organizationId=$(cat $response | sed 's/.*\"organizations\":\[{\"id\":\"//g' | sed 's/\".*//g')

    echo $organizationId > 'config/ORGANIZATION_ID'
fi