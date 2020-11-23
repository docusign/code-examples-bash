# List the envelope's documents
# This script uses the envelope_id stored in ../envelope_id.
# The envelope_id file is created by example eg002SigningViaEmail.sh or
# can be manually created.

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Configuration
# 1. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)
# 2. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Check that we have an envelope id
if [ ! -f config/ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg002SigningViaEmail.sh"
    echo ""
    exit -1
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

