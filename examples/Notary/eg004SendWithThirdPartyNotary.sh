#!/bin/bash
# Use embedded signing
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

ds_access_token_path="config/ds_access_token.txt"
api_account_id_path="config/API_ACCOUNT_ID"
document_path="demo_documents/World_Wide_Corp_lorem.pdf"

if [ ! -f $ds_access_token_path ]; then
    ds_access_token_path="../config/ds_access_token.txt"
    api_account_id_path="../config/API_ACCOUNT_ID"
    document_path="../demo_documents/World_Wide_Corp_lorem.pdf"
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat ${ds_access_token_path})

# Set up variables for full code example
# Note: Substitute these values with your own
ACCOUNT_ID=$(cat ${api_account_id_path})


# Create the envelope.
#         The signer recipient includes a clientUserId setting
#
#  document 1 (pdf) has tag /sn1/
#  The envelope will be sent to the signer.

base_path="https://demo.docusign.net/restapi"

# temp files:
request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
response=$(mktemp /tmp/response-eg-001.XXXXXX)
doc_base64=$(mktemp /tmp/eg-001-doc.XXXXXX)

cat demo_documents/World_Wide_Corp_Battle_Plan_Trafalgar.docx | base64 > $doc_base64

echo ""
echo "Sending the envelope request to Docusign..."

# Construct API headers

#ds-snippet-start:Notary4Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
    '--header' "Accept: application/json" \
    '--header' "Content-Type: application/json")
#ds-snippet-end:Notary4Step2

# Concatenate the different parts of the request
#ds-snippet-start:Notary4Step3
printf \
'{
  "emailSubject": "Please sign this document set",
  "documents": [
        {
            "documentBase64": "' >> $request_data
                cat $doc_base64 >> $request_data
                printf '",
            "name": "Order acknowledgement",
            "fileExtension": "html",
            "documentId": "1",
        },
  ],
  "recipients": {
    "signers": [
      {
        "clientUserId": "1000",
        "email": "'"${SIGNER_EMAIL}"'",
        "name": "'"${SIGNER_NAME}"'",
        "recipientId": "2",
        "routingOrder": "1",
        "notaryId": "1",
        "tabs": {
          "signHereTabs": [
            {
              "documentId": "1",
              "xPosition": "200",
              "yPosition": "235",
              "pageNumber": "1",
            },
            {
              "stampType": "stamp",
              "documentId": "1",
              "xPosition": "200",
              "yPosition": "150",
              "pageNumber": "1",
            },
          ],
        },
      }
    ],
    "notaries": [
      {
        "name": "Notary",
        "recipientId": "1",
        "routingOrder": "1",
        "recipientSignatureProviders": [
          {
            "sealDocumentsWithTabsOnly": "false",
            "signatureProviderName": "ds_authority_idv"
          }
        ],
        "tabs": {
          "notarySealTabs": [
            {
              "xPosition": "300",
              "yPosition": "235",
              "documentId": "1",
              "pageNumber": "1",
            },
        ],
          "signHereTabs": [
            {
              "xPosition": "300",
              "yPosition": "150",
              "documentId": "1",
              "pageNumber": "1",
            },
          ]
        },
        "notaryType": "remote",
        "notarySourceType": "thirdparty",
        "notaryThirdPartyPartner": "onenotary"
      }
    ]
  },
  "status": "sent"
}' >> $request_data
#ds-snippet-end:Notary4Step3

# Call Docusign to create the envelope

#ds-snippet-start:Notary4Step4
curl --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/envelopes \
     "${Headers[@]}" \
     --output ${response}
#ds-snippet-end:Notary4Step4

echo ""
echo "Response:" `cat $response`
echo ""

# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
echo "EnvelopeId: ${envelope_id}"


# cleanup
rm "$request_data"
rm "$response"
rm "$doc_base64"

echo ""
echo "Done."