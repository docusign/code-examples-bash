#!/bin/bash
# Create eSignature + CLM user with active status
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

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
# Step 2 end

# Step 3 Start
# Create a temporary file to store the response
response=$(mktemp /tmp/response-admin.XXXXXX)
echo ""
echo "Getting permission profiles..."
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/products/permission_profiles \
     "${Headers[@]}" \
     --output ${response})

CLM_PRODUCT_ID=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/.*\"product_id\"://' | sed 's/,".*//')
CLM_PERMISSION_PROFILE_ID=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/.*\"permission_profile_id\"://' | sed 's/,".*//')

ESIGN_PRODUCT_ID=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/.*\"product_id\"://' | sed 's/,".*//')
ESIGN_PERMISSION_PROFILE_ID=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/.*\"permission_profile_id\"://' | sed 's/,".*//')

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""
#Step 3 End

# Step 4 Start
echo ""
echo "Getting DS Groups..."
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/dsgroups \
     "${Headers[@]}" \
     --output ${response})

DS_GROUP_ID=$(cat $response | grep ds_group_id | sed 's/.*\"ds_group_id\"://' | sed 's/,".*//')

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Error:"
    echo ""
    cat $response
    exit 1
fi

echo ""
echo "Response:"
cat $response
echo ""
#Step 4 End

#Step 5 start
# Create a temporary file to store the request data
request_data=$(mktemp /tmp/request-admin-001.XXXXXX)

printf \
'
{
    "user_name": "Example User Name",
    "first_name": "Example",
    "last_name": "Name",
    "email": "examplename42@orobia.net",
    "auto_activate_memberships": true,
    "product_permission_profiles": [
        {
            "permission_profile_id": '$ESIGN_PERMISSION_PROFILE_ID',
            "product_id": '$ESIGN_PRODUCT_ID'
        },
        {
            "permission_profile_id": '$CLM_PERMISSION_PROFILE_ID',
            "product_id": '$CLM_PRODUCT_ID'
        }
    ],
    "ds_groups": [
        {
            "ds_group_id": '$DS_GROUP_ID'
        }
    ]
}' >$request_data
#Step 5 end

#Step 6 start
Status=$(
    curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/users/ \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response}
)

# If the status code returned is greater than 201 (OK/Accepted), display an error message with the API response
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Creating the new user has failed"
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""
#Step 6 end

# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo "Done."
echo ""
