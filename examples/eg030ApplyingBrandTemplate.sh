# Applying a Brand to a template

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
# Set up variables for full code example
ACCESS_TOKEN="{ACCESS_TOKEN}"
API_ACCOUNT_ID="{API_ACCOUNT_ID}"
BRAND_ID="{BRAND_ID}"
TEMPLATE_ID="{TEMPLATE_ID}"

#Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer {ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct the request body
# Create a temporary file to store the request body
request_data=$(mktemp /tmp/request-brand-001.XXXXXX)
printf \
'{
    "templateId": "'$TEMPLATE_ID'",
    "brandId": "'$BRAND_ID'",
    "templateRoles": [
        {
            "email": "alice.username@example.com",
            "name": "Alice UserName",
            "roleName": "signer"
        },
        {
            "email": "charlie.copy@example.com",
            "name": "Charlie Copy",
            "roleName": "cc"
        }
    ],
        "status": "sent"
}' >> $request_data

# Step 4: a) Call the eSignature API
#             b) Display the JSON response
# Create a temporary file to store the response
response=$(mktemp /tmp/response-brand.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${BASE_PATH}/v2.1/accounts/${API_ACCOUNT_ID}/envelopes \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
# If the Status code returned is greater than 201 (OK/Accepted), display an error message along with the API response
if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Creating a new envelope has failed."
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