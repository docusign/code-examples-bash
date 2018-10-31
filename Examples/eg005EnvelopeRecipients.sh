# Get the envelope recipients' details
# This script uses the envelope_id stored in ../envelope_id.
# The envelope_id file is created by example eg002SigningViaEmail.sh or
# can be manually created.


# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi
base_path="https://demo.docusign.com/restapi"

# Check that we have an envelope id
if [ ! -f ../ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg002SigningViaEmail.sh"
    echo ""
    exit -1
fi
envelope_id=`cat ../ENVELOPE_ID`

echo ""
echo "Sending the EnvelopeRecipients::list request to DocuSign..."
echo "Results:"
echo ""

curl --header "Authorization: Bearer {ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --request GET ${base_path}/v2/accounts/{ACCOUNT_ID}/envelopes/${envelope_id}/recipients

echo ""
echo ""
echo "Done."
echo ""

