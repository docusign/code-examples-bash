# Setting a permission profile

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check that we have a profile id
if [ ! -f config/PROFILE_ID ]; then
    echo ""
    echo "PROBLEM: Permission profile Id is needed. To fix: execute script eg024CreateingPermissionProfiles.sh"
    echo ""
    exit -1
fi

# Step 1: Obtain your OAuth token
# Set up variables for full code example
# Note: Substitute these values with your own
access_token=$(cat config/ds_access_token.txt)
account_id=$API_ACCOUNT_ID

profile_id=`cat config/PROFILE_ID`
#TODO: Set the group id by using an api call and a select chain to pick the groupID
read -p "Please enter the permissions group ID you wish to set a profile on: " group_id
export group_id


group_id=${group_id}
base_path="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
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
}}' >> $request_data

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
	exit 1
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

