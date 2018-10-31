# List the envelope's documents
# This script uses the envelope_id stored in ../envelope_id.
# The envelope_id file is created by example eg002SigningViaEmail.sh or
# can be manually created.

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi
base_path="https://demo.docusign.net/restapi"

# Check that we have an envelope id
if [ ! -f ../envelope_id ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg002SigningViaEmail.sh"
    echo ""
    exit -1
fi
envelope_id=`cat ../envelope_id`

echo ""
echo "Sending the EnvelopeDocuments::list request to DocuSign..."
echo "Results:"
echo ""

curl --header "Authorization: Bearer {ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --request GET ${base_path}/v2/accounts/{ACCOUNT_ID}/envelopes/${envelope_id}/documents

echo ""
echo ""
echo "Done."
echo ""

