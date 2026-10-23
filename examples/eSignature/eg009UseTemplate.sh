# Send a signing request via email using a DocuSign template

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check for a valid cc email and prompt the user if
#CC_EMAIL and CC_NAME haven't been set in the config file.
source ./examples/eSignature/lib/utils.sh
CheckForValidCCEmail

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)


# Check that we have a template id
if [ ! -f config/TEMPLATE_ID ]; then
    echo ""
    echo "PROBLEM: An template id is needed. Fix: execute script eg008CreateTemplate.sh"
    echo ""
    exit 0
fi
template_id=`cat config/TEMPLATE_ID`

base_path="https://demo.docusign.net/restapi"
# Step 1. Create the envelope request.
# temp files:
#ds-snippet-start:eSign9Step2
request_data=$(mktemp /tmp/request-eg-009.XXXXXX)

printf \
'{
    "templateId": "'"${template_id}"'",
    "templateRoles": [
        {
            "email": "'"${SIGNER_EMAIL}"'",
            "name": "'"${SIGNER_NAME}"'",
            "roleName": "signer"
        },
        {
            "email": "'"${CC_EMAIL}"'",
            "name": "'"${CC_NAME}"'",
            "roleName": "cc"
        }
    ],
    "status": "sent"
}' >> $request_data
#ds-snippet-end:eSign9Step2


#ds-snippet-start:eSign9Step3
response=$(mktemp /tmp/response-eg-009.XXXXXX)

echo ""
echo "Sending the envelope request to DocuSign..."
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
  --header "Content-Type: application/json" \
  --data-binary @${request_data} \
  --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
  --output ${response}
#ds-snippet-end:eSign9Step3

echo ""
echo "Response:"
cat $response
rm $response
rm $request_data
echo ""
echo ""
echo "Done."
echo ""
