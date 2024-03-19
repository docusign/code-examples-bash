# Get the envelope's custom field data
# This script uses the envelope ID stored in ../envelope_id.
# The envelope_id file is created by example eg016SetTabValues.sh or
# can be manually created.

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token
# Note: Substitute these values with your own
# Step 1 start
ACCESS_TOKEN=$(cat config/ds_access_token.txt)
# Step 1 end

#Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Construct your API headers
#ds-snippet-start:eSign18Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")
#ds-snippet-start:eSign18Step2

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

# Send a GET request to the Envelopes endpoint
#ds-snippet-start:eSign18Step3
response=$(mktemp /tmp/response-eg-018.XXXXXX)
Status=$(curl -w '%{http_code}' -i --request GET ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/custom_fields \
     "${Headers[@]}" \
     --output ${response})
#ds-snippet-end:eSign18Step3

echo "Results:"
echo ""

cat $response
echo ""
echo ""
echo "Done."
echo ""
