# How to unpause a signature workflow
# https://developers.docusign.com/docs/esign-rest-api/how-to/unpause-workflow/

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check that we have an Envelope ID
if [ ! -f config/ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: Envelope Id is needed. To fix: execute script eg032PauseSignatureWorkflow.sh"
    echo ""
    exit 0
fi
envelope_id=$(cat config/ENVELOPE_ID)

# Step 1: Create your API Headers
# Note: These values are not valid, but are shown for example purposes only!
ACCESS_TOKEN=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://demo.docusign.net/restapi"

# Step 2: Construct your API headers
# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer $ACCESS_TOKEN"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Create a temporary files to store the JSON body and response
request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)

# Step 3.Construct the JSON body for your envelope
printf \
    '{
  "workflow":
    {
        "workflowStatus": "in_progress"
    }
}' >>$request_data

# Step 4. Call the eSignature API
Status=$(curl --request PUT "${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}?resend_envelope=true" \
    "${Headers[@]}" \
    --data-binary @${request_data} \
    --output ${response})

if [[ "$Status" -gt "201" ]]; then
    echo ""
    echo "The call of the eSignature API has failed"
    echo ""
    cat $response
    exit 0
fi

echo ""
echo "Request:"
cat $request_data
echo ""

# Check the response
echo ""
echo $(cat $response)
echo ""

# Remove the temporary files
rm "$response"
rm "$request_data"
