#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/add-users-bulk-import/
# How to add users via bulk import
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Note: Substitute these values with your own
# Obtain your OAuth token
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.net/management"

ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)

# Construct your API headers
# Step 2 Start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Content-Disposition: filename=myfile.csv" \
					'--header' "Content-Type: text/csv")
# Step 2 End

# Create the bulk import request
# Step 3 Start
request_data=$(mktemp /tmp/request-oa.XXXXXX)

printf \
    'AccountID,UserName,UserEmail,PermissionSet
\"'${API_ACCOUNT_ID}'\",FirstLast1,exampleuser1@example.com,DS Viewer,
\"'${API_ACCOUNT_ID}'\",FirstLast2,exampleuser2@example.com,DS Viewer
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
# Step 3 End

#Pull the first Id from the JSON response
ID=$(cat $response | grep id | sed 's/.*{\"id\":\"//' | sed 's/\",.*//')
importId=${ID}

#Remove previous temp files
rm $response
rm $request_data

# Check the request status
echo ''
echo "Waiting for 20 seconds and check the status of the request..."
sleep 20
# Step 4 Start
curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/imports/bulk_users/${importId} \
    "${Headers[@]}" \
    --output ${response}
# Step 4 End
echo 'Response:'
echo ''
cat $response
echo ''

# Remove the temporary files
rm "$response"

echo ""
echo "Done."
echo ""
