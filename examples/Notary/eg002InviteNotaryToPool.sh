# Invite a notary to join your pool
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)
ORGANIZATION_ID=$(cat config/ORGANIZATION_ID)
base_path="https://notary-d.docusign.net/restapi"

# Create a temporary file to store the response
response=$(mktemp /tmp/response-notary.XXXXXX)

# Construct your API headers
#ds-snippet-start:Notary2Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end

#ds-snippet-start:Notary2Step3
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v1.0/organizations/${ORGANIZATION_ID}/pools \
     "${Headers[@]}" \
     --output ${response})

POOL_ID=$(cat "$response" | sed -n 's/.*"poolId":"\([^"]*\)".*/\1/p')
#ds-snippet-end

# Create a temporary file to store the request data
request_data=$(mktemp /tmp/request-notary-002.XXXXXX)

echo ""
read -p "Please enter a username for the new user: " NOTARY_NAME
read -p "Please enter an email for the new user: " NOTARY_EMAIL

#ds-snippet-start:Notary2Step4
printf \
'
{
  "email" : "'"${NOTARY_EMAIL}"'",
  "name" : "'"${NOTARY_NAME}"'",
}' >$request_data
#ds-snippet-end

echo ""
echo "Inviting ${NOTARY_NAME} to your organization's notary pool"
echo ""
echo "Pool id is ${POOL_ID}"
echo ""

#ds-snippet-start:Notary2Step5
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v1.0/organizations/${ORGANIZATION_ID}/pools/${POOL_ID}/invites \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
#ds-snippet-end

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
echo "Done."
echo ""
