#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/bulk-export-users/
# How to bulk-export user data
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"

ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Step 3: Construct the request body
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)

# Create the bulk export request
response=$(mktemp /tmp/response-oa.XXXXXX)

# Next, begin the process of creating the bulk export list by calling the
# /v2/organizations/{ORGANIZATION_ID}/exports/user_list endpoint.
# You can retrieve the resulting CSV data in a future step.

retryCount=0
downloadUrl=''
while [ $retryCount -le 5 ]; do
    echo ''
    echo 'Retriving Bulk Action Status...'
    echo ''
    curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/exports/user_list/${requestId} \
        "${Headers[@]}" \
        --output ${response}

    echo ''
    echo "Response:"
    echo ''
    cat $response
    echo ''
    #Check the status of the Bulk Action
    status=$(cat $response | grep status | sed 's/.*\"status\":\"//' | sed 's/\",.*//')

    if [ "$status" = "completed" ]; then
        echo ''
        echo 'Bulk Request has been completed'
        echo ''
        downloadUrl=$(cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\",.*//')
        break
    else
        echo ''
        echo 'Bulk Request has not been completed. Retrying in 5 seconds'
        echo ''
        sleep 5
        let retryCount=retryCount+1
    fi
done

# Check the request status
curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/exports/user_list/${requestId} \
    "${Headers[@]}" \
    --output ${response}

# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo "Done."
echo ""

echo "eg002BulkExportUserData.sh - Work in progress..."
