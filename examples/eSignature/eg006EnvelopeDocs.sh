# List the envelope's documents
#
# This script uses the envelope id stored in config/ENVELOPE_ID.
# config/ENVELOPE_ID will be populated by running example eg002SigningViaEmail.sh
# or can be entered manually.

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Construct your API headers.
#ds-snippet-start:eSign6Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Content-Type: application/json")
#ds-snippet-end:eSign6Step2

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Check that we have an envelope id
if [ ! -f config/ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg002SigningViaEmail.sh"
    echo ""
    exit 0
fi
envelope_id=`cat config/ENVELOPE_ID`

# Call the eSignature API
# Display the JSON response    
# Create a temporary file to store the response

response=$(mktemp /tmp/response-perm.XXXXXX)

#ds-snippet-start:eSign6Step3
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/documents \
     "${Headers[@]}" \
    --output ${response})
#ds-snippet-end:eSign6Step3
echo ""
echo "Sending the EnvelopeDocuments::list request to DocuSign..."
echo "Results:"
echo ""
cat $response 
echo ""
echo ""
echo "Done."
echo ""

# Remove the temporary file
rm "$response"

