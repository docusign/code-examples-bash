# Setting a permission profile

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Step 1: Obtain your OAuth token
# Set up variables for full code example
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)

# The following code shows how to get a list of account profile Ids
# Returns an array of permission profiles
# see https://developers.docusign.com/docs/esign-rest-api/reference/accounts/accountpermissionprofiles/
# base_path="https://demo.docusign.net/restapi"
# GET endpoint: /v2.1/accounts/{account_id}/permission_profiles

base_path="https://demo.docusign.net/restapi"

#Construct API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
'--header' "Accept: application/json" \
'--header' "Content-Type: application/json" )

# Create a temporary file to store the response
response=$(mktemp /tmp/response-bs.XXXXXX)

# Retrieve permission profile ids
 Status=$(curl -w '%{http_code}' -i --request GET "${base_path}/v2.1/accounts/${account_id}/permission_profiles" \
"${Headers[@]}" \
--output ${response})

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
echo ""
echo "Unable to retrieve your account's profiles."
echo ""
cat $response
exit 0
fi

cat $response

# Extract the account profile IDs from the profile data list
ProfileIds=`cat $response | grep -o -P '(?<=permissionProfileId\":\").*?(?=\")'`
arrProfileID=($ProfileIds)

# Select a profile Id
echo ""
echo "Select a profile Id:"
echo ""
PS3='Select a profile Id:'
select ID_TYPE in \
    "Administrator" \
    "Viewer" \
    "Sender" \
    "Use_Saved" \
    "Delete_Saved"; do
    case "$ID_TYPE" in 

    Administrator)
        echo ${arrProfileId[0]} > config/PROFILE_ID
        break
        ;;
    Viewer)
        echo ${arrProfileId[1]} > config/PROFILE_ID
        break
        ;;
    Sender)
        echo ${arrProfileId[2]} > config/PROFILE_ID
        break
        ;;
    Use_Saved)
        if [ -f config/PROFILE_ID ]; then
        break
        fi
        echo "No Profile Id found"
        ;;
    Delete_Saved)
        rm config/PROFILE_ID
        ;;
    esac
done

profile_id=`cat config/PROFILE_ID`

# The following code shows how to get a list of user groups
# Returns an array of user groups
# see https://developers.docusign.com/docs/esign-rest-api/reference/usergroups/groups/
# base_path="https://demo.docusign.net/restapi"
# GET endpoint: /v2.1/accounts/{account_id}/permission_profiles

base_path="https://demo.docusign.net/restapi"

#Construct API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
'--header' "Accept: application/json" \
'--header' "Content-Type: application/json" )

# Create a temporary file to store the response
response=$(mktemp /tmp/response-bs.XXXXXX)

# Retrieve group ids
 Status=$(curl -w '%{http_code}' -i --request GET "${base_path}/v2.1/accounts/${account_id}/groups" \
"${Headers[@]}" \
--output ${response})

#If the Status code returned is greater than 201 (OK / Accepted), display an error message along with the API response. 
if [[ "$Status" -gt "201" ]] ; then
echo ""
echo "Unable to retrieve your account's profiles."
echo ""
cat $response
exit 0
fi

cat $response

# Extract the user group IDs from the profile data list
GroupIds=`cat $response | grep -o -P '(?<=groupId\":\").*?(?=\")'`
arrGroupId=($GroupIds)

# Select User Group Id
echo ""
echo "Select a group Id"
echo ""
PS3='Select a group Id:'
select ID_TYPE in \
    "Administrators" \
    "Conditional_Group" \
    "Everyone" \
    "Use_Saved" \
    "Delete_Saved"; do
    case "$ID_TYPE" in 

    Administrators)
        echo ${arrGroupId[0]} > config/GROUP_ID
        group_id=${arrGroupId[0]}
        break
        ;;
    Conditional_Group)
        echo ${arrGroupId[1]} > config/GROUP_ID
        group_id=${arrGroupId[1]}
        break
        ;;
    Everyone)
        echo ${arrGroupId[2]} > config/GROUP_ID
        group_id=${arrGroupId[2]}
        break
        ;;
    Use_Saved)
        if [ -f config/GROUP_ID ]; then
        group_id=$(cat config/GROUP_ID)
        break
        fi
        echo "No Group Id found"
        ;;
    Delete_Saved)
        rm config/GROUP_ID
        ;;
    esac
done

export group_id
echo ""

base_path="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct your request body
# Create a temporary file to store the request body
request_data=$(mktemp /tmp/request-perm-001.XXXXXX)
printf \
'{
    "groups": [
        {
            "groupId": "'"${group_id}"'",
            "permissionProfileId": "'"${profile_id}"'" 
        }
            ]
}' >> $request_data

# Step 4: a) Call the eSignature API
#         b) Display the JSON response    
# Create a temporary file to store the response
response=$(mktemp /tmp/response-perm.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request PUT ${base_path}/v2.1/accounts/${account_id}/groups \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})

# If the Status code returned is greater than 399, display an error message along with the API response
if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Unable to set group permissions profile."
	echo ""
	cat $response
	exit 0
fi

echo ""
echo "Response:"
cat $response
echo ""

# Remove the temporary files
rm "$request_data"
rm "$response"
echo ""
echo ""
echo "Done."
echo ""

