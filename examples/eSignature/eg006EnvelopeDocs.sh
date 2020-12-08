# List the envelope's documents
#
# This script uses the envelope id stored in config/ENVELOPE_ID.
# config/ENVELOPE_ID will be populated by running example eg002SigningViaEmail.sh
# or can be entered manually.

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
access_token=$(cat config/ds_access_token.txt)

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

echo ""
echo "Sending the EnvelopeDocuments::list request to DocuSign..."
echo "Results:"
echo ""

# ***DS.snippet.0.start
curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/documents
# ***DS.snippet.0.end

echo ""
echo ""
echo "Done."
echo ""

