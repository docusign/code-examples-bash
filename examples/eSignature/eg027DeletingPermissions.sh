# Delete a permission profile

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
# Note: Substitute these values with your own
# Set up variables for full code example
access_token=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
permission_profile_id=`cat config/PROFILE_ID`
base_path="https://demo.docusign.net/restapi"

#Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: a) Call the eSignature API
#         b) Display the JSON response    
# Create a temporary file to store the response
response=$(mktemp /tmp/response-perm.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request DELETE ${base_path}/v2.1/accounts/${account_id}/permission_profiles/${permission_profile_id} \
     "${Headers[@]}" \
     --output ${response})

# If the Status code returned is greater than 399, display an error message along with the API response
if [[ "$Status" -gt "399" ]] ; then
    echo ""
	echo "Unable to delete the permission profile."
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

