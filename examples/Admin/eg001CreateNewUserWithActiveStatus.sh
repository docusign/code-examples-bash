#!/bin/bash
# https://developers.docusign.com/docs/admin-api/how-to/create-active-user/
# How to create a new user with active status
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

# Construct your API headers
# Step 2 start
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
# Step 2 end
# Get permission profiles

response=$(mktemp /tmp/response-oa.XXXXXX)
# Step 3 Start
Status=$(curl --request GET ${base_path}/v2/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/permissions \
"${Headers[@]}" \
--output ${response})
#Step 3 End

# If the status code returned a response greater than 201, display an error message
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Can't get user's data..."
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Response: "
echo ""
cat $response
echo ""

# Return strings between 'name:"' and '="' for the profile names
profile_names=`cat $response | grep -o -P '(?<=name\":\").*?(?=\")'`

#Return strings between 'id":' and ',' for the profile ids
profile_ids=`cat $response | grep -o -P '(?<=id\":).*?(?=\,)'`

arr_profile_ids=($profile_ids)
profiles_count=$(echo "$profile_names" | grep -c '^')

if [ -z "$profile_names" ]; then
    # 0 entries so exit
    echo ""
    echo "Error:"
    echo ""
    echo "You must create an eSignature permission profile before running this code example"
    exit 0
elif [ "$profiles_count" -eq "1" ]; then
    # There's only one entry so use that
    PERMISSION_PROFILE_ID=$profile_ids
else
    echo ""
    echo ""
    PS3='Select a permission profile to assign to the new user: '
    IFS=$'\n'
    # Display menu of profile names and use selection number for the profile id array subscript
    select permission_profile in $profile_names; do
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$profiles_count" ]; then
            PERMISSION_PROFILE_ID=${arr_profile_ids[$REPLY-1]}
            break
        fi
    done
fi

echo ""
echo "PERMISSION_PROFILE_ID: " $PERMISSION_PROFILE_ID
echo ""

# Retrieve group ids
response2=$(mktemp /tmp/response2-oa.XXXXXX)
# Step 4 Start
Status=$(curl -w '%{http_code}' -i --request GET "${base_path}/v2/organizations/${ORGANIZATION_ID}/accounts/${API_ACCOUNT_ID}/groups" \
        "${Headers[@]}" \
        --output ${response2})
# Step 4 End
echo ""
echo "Response: "
echo ""
cat $response2
echo ""

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
echo ""
echo "Unable to retrieve your account's profiles."
echo ""
exit 0
fi

group_names=`cat $response2 | grep -o -P '(?<=name\":\").*?(?=\")'`
groups_count=$(echo "$group_names" | grep -c '^')
group_ids=`cat $response2 | grep -o -P '(?<=id\":).*?(?=\,)'`
arr_group_ids=($group_ids)

if [ -z "$group_names" ]; then
    # 0 entries so exit
    echo ""
    echo "Error:"
    echo ""
    echo "You must create a DS Group before running this code example"
    exit 0
elif [ "$groups_count" -eq "1" ]; then
    # There's only one entry so use that
    GROUP_ID=$group_ids
else
    echo ""
    PS3='Select a DS Group to assign to the new user : '
    IFS=$'\n'
    select group_name in $group_names; do
        # Display menu of profile names and use selection number for the profile id array subscript
        if [ "$REPLY" -gt "0" ] && [ "$REPLY" -le "$groups_count" ]; then
            GROUP_ID=${arr_group_ids[$REPLY-1]}
            break
        fi
    done
fi

echo ""
echo "GROUP_ID: " $GROUP_ID
echo ""

permission_profile_id=$PERMISSION_PROFILE_ID
group_id=$GROUP_ID

# Prompt for new user info. Note that there is no check for special characters
read -p "Please enter a username for the new user: " USER_NAME
read -p "Please enter the first name for the new user: " FIRST_NAME
read -p "Please enter the last name for the new user: " LAST_NAME
read -p "Please enter an email for the new user: " USER_EMAIL
echo ""


# Create a temporary file to store the JSON body
request_data=$(mktemp /tmp/request-cw-001.XXXXXX)
# Construct the request body
#Step 5 start
printf \
'{
  "user_name": \"'${USER_NAME}'\",
  "first_name": \"'${FIRST_NAME}'\",
  "last_name": \"'{LAST_NAME}'\",
  "email": \"'${USER_EMAIL}'\",
  "auto_activate_memberships": true,
  "accounts": [
    {
      "id": \"'${API_ACCOUNT_ID}'\",
      "permission_profile": {
        "id": \"'${permission_profile_id}'\",
      },
      "groups": [
        {
          "id": \"'${group_id}'\",
        }
      ]
    }
  ]
}
' >>$request_data
#Step 5 end

# Call the DocuSign Admin API
#Step 6 start
response3=$(mktemp /tmp/response3-oa.XXXXXX)
Status=$(curl --request POST ${base_path}/v2/organizations/${ORGANIZATION_ID}/users \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response3})
#Step 6 end

# If the status code returned a response greater than 201, display an error message
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Failed to create a new user"
    echo ""
    cat $response3
    exit 0
fi

echo ''
echo 'Response:'
echo ''
cat $response3
echo ''

# Remove the temporary files
rm "$request_data"
rm "$response"
rm "$response2"
rm "$response3"

echo ""
echo "Done."
