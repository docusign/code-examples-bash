# Returns the status of whether or not jurisdictions are disabled
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Step 1 start
# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)
# Step 1 end

# Set up variables for full code example
# Note: Substitute these values with your own
API_ACCOUNT_ID=$(cat config/API_ACCOUNT_ID)
base_path="https://notary-d.docusign.net/restapi"

# Create a temporary file to store the response
response=$(mktemp /tmp/response-notary.XXXXXX)

echo "Sending the jurisdiction status request to DocuSign..."
echo ""
echo "Results:"
# Step 2 start
#ds-snippet-start:Notary3Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")

Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v1.0/accounts/${API_ACCOUNT_ID}/jurisdictions \
     "${Headers[@]}" \
     --output ${response})
#ds-snippet-end
# Step 2 end

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
