# Send a signing request via email using a DocuSign template

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Configuration
# 1. Search for and update '{USER_EMAIL}' and '{USER_FULLNAME}'.
#    They occur and re-occur multiple times below.
# 2. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)
# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

# Check that we have a template id
if [ ! -f ../TEMPLATE_ID ]; then
    echo ""
    echo "PROBLEM: An template id is needed. Fix: execute script eg008CreateTemplate.sh"
    echo ""
    exit -1
fi
template_id=`cat config/TEMPLATE_ID`

base_path="https://demo.docusign.net/restapi"

# ***DS.snippet.0.start
# Step 1. Create the envelope request.
# temp files:
response=$(mktemp /tmp/response-eg-009.XXXXXX)

echo ""
echo "Sending the envelope request to DocuSign..."

curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --data-binary \
"{
    \"templateId\": \"${template_id}\",
    \"templateRoles\": [
        {
            \"email\": \"${SIGNER_EMAIL}\",
            \"name\": \"${SIGNER_NAME}\",
            \"roleName\": \"signer\"
        },
        {
            \"email\": \"${CC_EMAIL}\",
            \"name\": \"${CC_NAME}\",
            \"roleName\": \"cc\"
        }
    ],
    \"status\": \"sent\"
}" \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output ${response}
# ***DS.snippet.0.end

echo ""
echo "Response:"
cat $response
rm $response
echo ""
echo ""
echo "Done."
echo ""


