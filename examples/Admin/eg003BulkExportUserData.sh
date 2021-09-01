#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/bulk-export-users/
# How to bulk-export user data
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"

ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)

# Construct your API headers
# Step 2 Start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
# Step 2 End

# Construct the request body to retrieve the user list
# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
response=$(mktemp /tmp/response-oa.XXXXXX)
response2=$(mktemp /tmp/response-oa.XXXXXX)

printf \
'{
    "type": "organization_memberships_export"
}
' >>$request_data

curl --request POST ${base_path}/v2/organizations/${ORGANIZATION_ID}/exports/user_list \
        "${Headers[@]}" \
        --data-binary @${request_data} \
        --output ${response}

# Create the bulk export request
requestId=`cat $response | cut -f1 -d"," | sed 's/{//g' | sed 's/.*\"id\"://' | sed 's/\"//g'`
# Step 3 Start
retryCount=0
downloadUrl=''
while [ $retryCount -le 5 ]; do
    echo ''
    echo 'Retrieving Bulk Action Status...'
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
    echo "Status: $status"

    if [ "$status" = "completed" ]; then
        echo ''
        echo 'Bulk Request has been completed'
        echo ''
        downloadUrl=$(cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\",.*//')
        echo "Download Url: $downloadUrl"
        let retryCount=6
    else
        echo ''
        echo 'Bulk Request has not been completed. Retrying in 5 seconds'
        echo ''
        sleep 5
        let retryCount=retryCount+1
    fi
done
# Step 3 End

# Check the request status
# Step 4 Start
curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/exports/user_list/${requestId} \
    "${Headers[@]}" \
    --output ${response}
# Step 4 End
echo ''
echo "Response:"
echo ''
cat $response
echo ''

# Download the exported user data
# Step 5 Start
curl --request GET "${downloadUrl}" \
	"${Headers[@]}" \
	--output ${response2}
# Step 5 End
echo ''
cat $response2

echo ''
echo "Export data to file myfile.csv..."
cat $response2 > myfile.csv

# Remove the temporary files
rm "$request_data"
rm "$response"
rm "$response2"

echo ""
echo "Done."
echo ""
