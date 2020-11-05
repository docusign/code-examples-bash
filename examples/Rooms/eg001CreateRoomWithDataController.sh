# https://developers.docusign.com/docs/rooms-api/how-to/create-room-with-data/
# Create Room With Data
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Configuration
# 1. Search for and update '{USER_EMAIL}' and '{USER_FULLNAME}'.
#    They occur and re-occur multiple times below.
# 2. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)
# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Construct the request body
# Create a temporary file to store the request body
request_data=$(mktemp /tmp/request-brand-001.XXXXXX)
printf \
    '{
        "brandName": "Sample Corp.",
        "defaultBrandLanguage": "en"
    }' >>$request_data

# a) Call the eSignature API
# b) Display the JSON response
# Create a temporary file to store the response
response=$(mktemp /tmp/response-brand.XXXXXX)

Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/brands \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})

# If the Status code returned is greater than 201 (OK/Accepted), display an error message along with the API response
if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "Unable to create a new brand."
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
