# Applying a Brand to a template

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check that we have a template id
if [ ! -f config/TEMPLATE_ID ]; then
    echo ""
    echo "PROBLEM: Template Id needed. To fix: execute script eg008CreateTemplate.sh"
    echo ""
    exit -1
fi
template_id=`cat config/TEMPLATE_ID`

# Check that we have a brand id
if [ ! -f config/BRAND_ID ]; then
    echo ""
    echo "PROBLEM: Brand Id is needed. To fix: execute script eg028CreateingABrand.sh"
    echo ""
    exit -1
fi
brand_id=`cat config/BRAND_ID`



# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
# Set up variables for full code example
access_token=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
brand_id=$brand_id
template_id=$template_id
base_path="https://demo.docusign.net/restapi"

#Step 2: Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer $access_token" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")

# Step 3: Construct the request body
# Create a temporary file to store the request body
request_data=$(mktemp /tmp/request-brand-001.XXXXXX)
printf \
'{
    "templateId": "'$template_id'",
    "brandId": "'$brand_id'",
    "templateRoles": [
        {
            "email": "'"${SIGNER_EMAIL}"'",
            "name": "'"${SIGNER_NAME}"'",
            "roleName": "signer"
        },
        {
            "email": "'"${CC_EMAIL}"'",
            "name": "'"${CC_NAME}"'",
            "roleName": "cc"
        }
    ],
        "status": "sent"
}' >> $request_data

# Step 4: a) Call the eSignature API
#             b) Display the JSON response
# Create a temporary file to store the response
response=$(mktemp /tmp/response-brand.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
# If the Status code returned is greater than 399, display an error message along with the API response
if [[ "$Status" -gt "399" ]] ; then
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
echo ""
echo ""
echo "Done."
echo ""

