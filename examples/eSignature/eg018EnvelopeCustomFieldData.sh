# Get the envelope's custom field data
# This script uses the envelope ID stored in ../envelope_id.
# The envelope_id file is created by example eg016SetTabValues.sh or
# can be manually created.

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

#Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Check that we have an template ID
if [ ! -f config/ENVELOPE_ID ]; then
    echo ""
    echo "PROBLEM: An envelope id is needed. Fix: execute script eg016SetTabValues.sh"
    echo ""
    exit 0
fi
envelope_id=`cat config/ENVELOPE_ID`

echo ""
echo "Sending the EnvelopeCustomFields::list request to DocuSign..."

#Step 2: a) Create your authorization headers
#        b) Send a GET request to the Envelopes endpoint
response=$(mktemp /tmp/response-eg-018.XXXXXX)
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/custom_fields \
     --output ${response}
echo "Results:"
echo ""

cat $response
echo ""
echo ""
echo "Done."
echo ""
