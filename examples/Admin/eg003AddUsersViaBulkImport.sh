#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/add-users-bulk-import/
# How to add users via bulk import
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

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Content-Disposition: filename=myfile.csv" \
					'--header' "Content-Type: text/csv")

# Step 3. Create the bulk import request
request_data=$(mktemp /tmp/request-oa.XXXXXX)

printf \
    'AccountID,UserName,UserEmail,PermissionSet
\"'${ACCOUNT_ID}'\",FirstLast1,exampleuser1@example.com,DS Viewer,
\"'${ACCOUNT_ID}'\",FirstLast2,exampleuser2@example.com,DS Viewer
' >>$request_data

# Create a temporary file to store the response
response=$(mktemp /tmp/response-oa.XXXXXX)
curl --request POST ${base_path}/v2/organizations/${ORGANIZATION_ID}/imports/bulk_users/add \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}

echo ''
echo 'Response:'
echo ''
cat $response
echo ''

#Pull the first Id from the JSON response
ID=$(cat $response | grep id | sed 's/.*{\"id\":\"//' | sed 's/\",.*//')
importId=${ID}

#Remove previous temp files
rm $response
rm $request_data

# Step 4. Check the request status
echo ''
echo "Waiting for 20 seconds and check the status of the request..."
sleep 20
curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/imports/bulk_users/${importId} \
    "${Headers[@]}" \
    --output ${response}

echo 'Response:'
echo ''
cat $response
echo ''

# Remove the temporary files
rm "$response"

echo ""
echo "Done."
echo ""
