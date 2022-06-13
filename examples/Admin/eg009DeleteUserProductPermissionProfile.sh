#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/create-active-user/
# How to create a new user with active status
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

EMAIL_ADDRESS=$(cat config/ESIGN_CLM_USER_EMAIL)

if [ -z "$EMAIL_ADDRESS" ]; then
  echo "Please run example 2: Create_Active_CLM_ESign_User before running this code example"
  exit 1
fi

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
# Step 2 end

response=$(mktemp /tmp/response-oa.XXXXXX)
curl --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/products/permission_profiles/users?email=${EMAIL_ADDRESS} \
    "${Headers[@]}" \
    --output ${response}

echo ""
cat $response
echo ""

CLM_PRODUCT_ID="37f013eb-7012-4588-8028-357b39fdbd00"
ESIGN_PRODUCT_ID="f6406c68-225c-4e9b-9894-64152a26fa83"

echo ""
echo ""
echo "Delete user product permission profile for the following email: $EMAIL_ADDRESS"
echo ""

PS3='Which product permission profile would you like to delete? '
select choice in eSignature CLM
do
  echo $choice
  product=$choice
  break
done

if [ "$product" == "eSignature" ]; then
  PRODUCT_ID=$ESIGN_PRODUCT_ID
else
  PRODUCT_ID=$CLM_PRODUCT_ID
fi

request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
# Construct the request body
#Step 3 start
printf \
'{
  "user_email": "'${EMAIL_ADDRESS}'",
  "product_ids": [
    "'${PRODUCT_ID}'",
  ]
}
' >>$request_data

cat $request_data

#Delete User Permission Profile
curl -w '%{http_code}' -i --request DELETE "${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/products/users" \
  "${Headers[@]}" \
  --data-binary @${request_data} \
  --output ${response}
echo ""
echo "Response: "
echo ""
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"

echo ""
echo "Done."
echo ""
