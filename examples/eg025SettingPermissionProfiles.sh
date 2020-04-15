# Setting a permission profile

# Step 1: Obtain your OAuth token
# Set up variables for full code example
# Note: Substitute these values with your own
ACCESS_TOKEN="{ACCESS_TOKEN}"
API_ACCOUNT_ID="{API_ACCOUNT_ID}"
PROFILE_ID="{PROFILE_ID}"
GROUP_ID="{GROUP_ID}"


# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi
BASE_PATH="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct your request body
# Create a temporary file to store the request body
request_data=$(mktemp /tmp/request-perm-001.XXXXXX)
printf \
"{
    \"groups\": [
        {
            \"groupId\": "${GROUP_ID}",
            \"permissionProfileId\": "${PROFILE_ID}" 
        }
            ]
}}" >> $request_data

# Step 4: a) Call the eSignature API
#         b) Display the JSON response    
# Create a temporary file to store the response
response=$(mktemp /tmp/response-perm.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request PUT ${BASE_PATH}/v2.1/accounts/${API_ACCOUNT_ID}/groups \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})

# If the Status code returned is greater than 201 (OK/Accepted), display an error message along with the API response
if [[ "$Status" -gt "201" ]] ; then
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
