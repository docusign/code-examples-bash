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

# Construct your API headers
#ds-snippet-start:Admin8Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:Admin8Step2

EMAIL_ADDRESS=$(cat config/ESIGN_CLM_USER_EMAIL)

if [ -z "$EMAIL_ADDRESS" ]; then
  echo "Please run example 2: Create_Active_CLM_ESign_User before running this code example"
  exit 1
fi


# Create a temporary file to store the response
response=$(mktemp /tmp/response-admin.XXXXXX)
echo ""
echo "Getting permission profiles..."
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/products/permission_profiles \
     "${Headers[@]}" \
     --output ${response})

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

echo ""

CLM_PRODUCT_ID=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/.*\"product_id\"://' | sed 's/,".*//')
clm_profile_names=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/,/\n/g' | grep permission_profile_name | sed 's/.*\"permission_profile_name\":\"//g' | sed 's/\".*//g')
clm_profiles_count=$(echo "$clm_profile_names" | grep -c '^')

ESIGN_PRODUCT_ID=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/.*\"product_id\"://' | sed 's/,".*//')
esign_profile_names=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/,/\n/g' | grep permission_profile_name | sed 's/.*\"permission_profile_name\":\"//g' | sed 's/\".*//g')
esign_profiles_count=$(echo "$esign_profile_names" | grep -c '^')

echo ""
echo "Update user product permission profile for the following email: $EMAIL_ADDRESS"
echo ""

PS3='Would you like to update the permission profile for the eSignature or CLM product? '
select choice in eSignature CLM
do
  echo $choice
  product=$choice
  break
done


if [ "$product" == "eSignature" ]; then
    PRODUCT_ID=$ESIGN_PRODUCT_ID
    echo ""
    PS3='Select an eSignature permission profile to add: '
    IFS=$'\n'
    select esign_permission_profile in $esign_profile_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$esign_profiles_count" ]; then
            PERMISSION_PROFILE_ID=$(cat $response | sed 's/}]}/\n/' | grep ESign | sed 's/.*\"permission_profiles\"://' | sed 's/},/\n/g' | grep $esign_permission_profile | sed 's/.*\"permission_profile_id\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
else
    PRODUCT_ID=$CLM_PRODUCT_ID
    echo ""
    PS3='Select a CLM permission profile to assign to the new user: '
    IFS=$'\n'
    select clm_permission_profile in $clm_profile_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$clm_profiles_count" ]; then
            PERMISSION_PROFILE_ID=$(cat $response | sed 's/}]}/\n/' | grep CLM | sed 's/.*\"permission_profiles\"://' | sed 's/},/\n/g' | grep $clm_permission_profile | sed 's/.*\"permission_profile_id\":\"//g' | sed 's/\".*//g')
            break
        fi
    done
fi

request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
# Construct the request body
#ds-snippet-start:Admin8Step3
printf \
'{
  "email": "'${EMAIL_ADDRESS}'",
  "product_permission_profiles": [
    {
      "product_id": '${PRODUCT_ID}',
      "permission_profile_id": '${PERMISSION_PROFILE_ID}',
    }
  ]
}
' >>$request_data
#ds-snippet-end:Admin8Step3
echo $request_data
Add user permission profile
#ds-snippet-start:Admin8Step4
curl -w '%{http_code}' -i --request POST "${base_path}/v2.1/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/products/permission_profiles/users" \
  "${Headers[@]}" \
  --data-binary @${request_data} \
  --output ${response}
#ds-snippet-end:Admin8Step4
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
