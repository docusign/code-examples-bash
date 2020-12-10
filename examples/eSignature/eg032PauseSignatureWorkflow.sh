# How to pause a signature workflow
# https://developers.docusign.com/docs/esign-rest-api/how-to/pause-workflow/

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Check for a valid cc email address
while [[ $CC_EMAIL != *"@"* ]]; do
    echo ""
    echo "Current cc email address is " $CC_EMAIL
    read -p "Enter an email address for the cc recipient different from the signer: " CC_EMAIL
    if [[ $CC_NAME == *"{"* || CC_NAME == "" ]] ; then
        echo ""
        echo "Current cc name is " $CC_NAME
        read -p "Enter a name for the CC Recipient: " CC_NAME
    fi
    echo ""
    echo "CC_EMAIL is " $CC_EMAIL
    echo "CC_NAME is " $CC_NAME
done

# Step 1: Create your API Headers
# Note: These values are not valid, but are shown for example purposes only!
access_token=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://demo.docusign.net/restapi"

# Get values form the settings.txt config file
SIGNER1_EMAIL=$SIGNER_EMAIL
SIGNER1_NAME=$SIGNER_NAME
SIGNER2_EMAIL=$CC_EMAIL
SIGNER2_NAME=$CC_NAME

# Step 2: Construct your API headers
# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer ${access_token}"
  '--header' "Accept: application/json"
  '--header' "Content-Type: application/json")

# Step 3. Construct the request body
# Create a temporary files to store the JSON body and response
request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)
# Create the request body
printf \
  '{
  "documents": [
    {
      "documentBase64": "DQoNCg0KDQoJCVdlbGNvbWUgdG8gdGhlIERvY3VTaWduIFJlY3J1aXRpbmcgRXZlbnQNCgkJDQoJCQ0KCQlQbGVhc2UgU2lnbiBpbiENCgkJDQoJCQ0KCQk=",
      "documentId": "1",
      "fileExtension": "txt",
      "name": "Welcome"
    }
  ],
  "emailSubject": "EnvelopeWorkflowTest",
  "workflow":
  {
    "workflowSteps":
    [
        {
            "action": "pause_before",
            "triggerOnItem": "routing_order",
            "itemId": "2"
        }
    ]
  },
  "recipients": {
    "signers": [
      {
        "email": "'"${SIGNER1_EMAIL}"'",
        "name": "'"${SIGNER1_NAME}"'",
        "recipientId": "1",
        "routingOrder": "1",
        "tabs": {
          "signHereTabs": [
            {
              "documentId": "1",
              "pageNumber": "1",
              "tabLabel": "Sign Here",
              "xPosition": "200",
              "yPosition": "200"
            }
          ]
        }
      },
      {
        "email": "'"${SIGNER2_EMAIL}"'",
        "name": "'"${SIGNER2_NAME}"'",
        "recipientId": "2",
        "routingOrder": "2",
        "tabs": {
          "signHereTabs": [
            {
              "documentId": "1",
              "pageNumber": "1",
              "tabLabel": "Sign Here",
              "xPosition": "300",
              "yPosition": "200"
            }
          ]
        }
      }
    ]
  },
"status": "Sent"
}
' >>$request_data

# Step 4. Call the eSignature API
Status=$(curl --request POST "${base_path}/v2.1/accounts/${account_id}/envelopes" \
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

# Obtain the Envelope ID from the JSON response
envelope_id=$(cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//')
echo "Envelope Id: $envelope_id"
echo ""

# Store the envelope_id into the config file
echo $envelope_id >config/ENVELOPE_ID

# Remove the temporary files
rm "$response"
rm "$request_data"
