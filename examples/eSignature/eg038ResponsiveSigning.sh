#!/bin/sh
# Signable HTML document
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi


# Check for a valid cc email and prompt the user if 
#CC_EMAIL and CC_NAME haven't been set in the config file.
source ./examples/eSignature/lib/utils.sh
CheckForValidCCEmail


ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"
html_document_path="demo_documents/order_form.html"

# temp files:
request_data=$(mktemp /tmp/request-eg-038.XXXXXX)
response=$(mktemp /tmp/response-eg-038.XXXXXX)

echo ""
echo "Sending the envelope request to DocuSign..."

# Fetch doc and encode
#ds-snippet-start:eSign38Step2
html_with_tabs=`cat $html_document_path \
    | sed 's/sn1/<ds-signature data-ds-role="Signer"\\/>/g' \
    | sed 's/l1q/<input data-ds-type="number" name="l1q"\\/>/g' \
    | sed 's/l2q/<input data-ds-type="number" name="l2q"\\/>/g' \
    | sed 's/\\"/\\\\\\\\"/g'`

printf \
'{
    "emailSubject": "Example Signing Document",
    "documents": [
        {
            "name": "Lorem Ipsum",
            "documentId": "1",
            "htmlDefinition": 
            {
                "source":  "'"${html_with_tabs}"'",
            }            
        }
    ],
    "recipients": {
        "signers": [
            {
                "email": "'"${SIGNER_EMAIL}"'",
                "name": "'"${SIGNER_NAME}"'",
                "recipientId": "1",
                "routingOrder": "1",
                "clientUserId": "1000",
                "signerRole": "Signer",
                "tabs": {
                    "formulaTabs": [
                        {
                            "anchorString": "/l1e/", "anchorUnits": "pixels",
                            "anchorXOffset": "105", "anchorYOffset": "-8",
                            "disableAutoSize": "false", "font": "helvetica",
                            "fontSize": "size11", "formula": "[l1q] * 5",
                            "locked": "true", "required": "true",
                            "roundDecimalPlaces": "0", "tabLabel": "l1e"
                        },
                        {
                            "anchorString": "/l2e/", "anchorUnits": "pixels",
                            "anchorXOffset": "105", "anchorYOffset": "-8",
                            "disableAutoSize": "false", "font": "helvetica",
                            "fontSize": "size11", "formula": "[l2q] * 150",
                            "locked": "true", "required": "true",
                            "roundDecimalPlaces": "0", "tabLabel": "l2e"
                        },
                        {
                            "anchorString": "/l3t/", "anchorUnits": "pixels",
                            "anchorXOffset": "105", "anchorYOffset": "-8",
                            "bold": "true", "disableAutoSize": "false",
                            "font": "helvetica", "fontSize": "size11",
                            "formula": "[l1e] + [l2e]", "locked": "true",
                            "required": "true", "roundDecimalPlaces": "0",
                            "tabLabel": "l3t"
                        },
                    ],
                }
            }
        ],
       "carbonCopies": [
            {
                "email": "'"${CC_EMAIL}"'",
                "name": "'"${CC_NAME}"'",
                "recipientId": "2",
                "routingOrder": "1"
            }
        ]
    },
    "status": "sent"
}' >> $request_data
#ds-snippet-end:eSign38Step2

#ds-snippet-start:eSign38Step3
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output ${response}
#ds-snippet-end:eSign38Step3

echo ""
echo "Response:" `cat $response`
echo ""

envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
echo "EnvelopeId: ${envelope_id}"

# temp files:
request_data=$(mktemp /tmp/request-eg-038.XXXXXX)
response=$(mktemp /tmp/response-eg-038.XXXXXX)

printf \
'{
    "returnUrl": "http://httpbin.org/get",
    "authenticationMethod": "none",
    "email": "'"${SIGNER_EMAIL}"'",
    "userName": "'"${SIGNER_NAME}"'",
    "clientUserId": 1000,
}' >> $request_data

echo ""
echo "Requesting the url for the responsive signing..."
echo ""
Status=$(curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/views/recipient \
     --output ${response})

if [[ "$Status" -gt "201" ]] ; then
    echo ""
	echo "Signing request failed."
	echo ""
	cat $response
	exit 0
fi

signing_url=`cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\".*//'`

echo ""
echo "The responsive signing URL is ${signing_url}"
echo ""
echo "It is only valid for five minutes. Attempting to automatically open your browser..."

if which xdg-open &> /dev/null  ; then
  xdg-open "$signing_url"
elif which open &> /dev/null    ; then
  open "$signing_url"
elif which start &> /dev/null   ; then
  start "$signing_url"
fi

# cleanup
rm "$request_data"
rm "$response"

echo ""
echo "Done."