# Set Envelope Tab Data

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Temp files:
request_data=$(mktemp /tmp/request-eg-016.XXXXXX)
response=$(mktemp /tmp/response-eg-016.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-016-doc1.XXXXXX)

# Construct your API headers
#ds-snippet-start:eSign16Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:eSign16Step2

echo ""
echo "Sending the envelope request to DocuSign..."

# Fetch doc and encode
cat demo_documents/World_Wide_Corp_salary.docx | base64 > $doc1_base64

# Construct the JSON body for your envelope
#ds-snippet-start:eSign16Step3
printf \
'{
    "customFields": {
        "textCustomFields": [{
            "name": "salary",
            "required": "false",
            "show": "true",
            "value": "123000"
        }]
    },
    "documents": [
      {
        "documentBase64": "' > $request_data
          cat $doc1_base64 >> $request_data
          printf '",
        "documentId": "1",
        "fileExtension": "docx",
        "name": "Lorem Ipsum"
     }
    ],
    "emailBlurb": "Sample text for email body",
    "emailSubject": "Please Sign",
    "envelopeIdStamping": "true",
    "recipients": {
        "signers": [{
            "clientUserId": "1000",
            "email": "'"${SIGNER_EMAIL}"'",
            "name": "'"${SIGNER_NAME}"'",
            "recipientId": "1",
            "routingOrder": "1",
            "tabs": {
                "signHereTabs": [{
                    "anchorString": "/sn1/",
                    "anchorUnits": "pixels",
                    "anchorXOffset": "20",
                    "anchorYOffset": "10"
                }],
                "textTabs": [{
                    "anchorString": "/legal/",
                    "anchorUnits": "pixels",
                    "anchorXOffset": "5",
                    "anchorYOffset": "-9",
                    "bold": "true",
                    "font": "helvetica",
                    "fontSize": "size11",
                    "locked": "false",
                    "tabId": "legal_name",
                    "tabLabel": "Legal name",
                    "value": "'"${SIGNER_NAME}"'"
                }, {
                    "anchorString": "/familiar/",
                    "anchorUnits": "pixels",
                    "anchorXOffset": "5",
                    "anchorYOffset": "-9",
                    "bold": "true",
                    "font": "helvetica",
                    "fontSize": "size11",
                    "locked": "false",
                    "tabId": "familiar_name",
                    "tabLabel": "Familiar name",
                    "value": "'"${SIGNER_NAME}"'"
                }],
                "numericalTabs" : [
                 {
                    "pageNumber" : "1",
                    "documentID" : "1",
                    "xPosition" : "210",
                    "yPosition" : "235",
                    "height" : "20",
                    "width" : "70",
                    "minNumericalValue" : "0",
                    "maxNumericalValue" : "1000000",
                    "validationType" : "Currency",
                    "bold": "true",
                    "font": "helvetica",
                    "fontSize": "size11",
                    "tabId": "salary",
                    "tabLabel": "Salary",
                    "numericalValue": "123000",
                    "localePolicy" : {
                      "cultureName" : "en-US",
                      "currencyCode": "usd",
                      "currencyPositiveFormat" : "csym_1_comma_234_comma_567_period_89",
                      "currencyNegativeFormat" : "minus_csym_1_comma_234_comma_567_period_89",
                      "useLongCurrencyFormat" : "true"
                    }
                }]
            }
        }]
    },
    "status": "Sent"
}' >> $request_data
#ds-snippet-end:eSign16Step3
# a) Create your authorization headers
# b) Send a POST request to the Envelopes endpoint

#ds-snippet-start:eSign16Step4
Status=$(curl --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})
#ds-snippet-end:eSign16Step4

echo ""
echo "Response:"
cat $response
echo ""

# Pull out the envelope ID
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":"//' | sed 's/\",.*//'` 
echo ""

echo "EnvelopeId: ${envelope_id}"

# Save the envelope ID for use by other scripts
echo ${envelope_id} > config/ENVELOPE_ID


# Create a recipient view (an embedded signing view)
#         that the signer will directly open in their browser to sign
#
# The return URL is normally your own web app. DocuSign will redirect
# the signer to the return URL when the DocuSign signing completes.
# For this example, we'll use http://httpbin.org/get to show the 
# query parameters passed back from DocuSign

echo ""
echo "Requesting the url for the embedded signing..."
#ds-snippet-start:eSign16Step5
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary '
{
    "returnUrl": "http://httpbin.org/get",
    "authenticationMethod": "none",
    "email": "'"${SIGNER_EMAIL}"'",
    "userName": "'"${SIGNER_NAME}"'",
    "clientUserId": 1000,
}' \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/views/recipient \
     --output ${response}
#ds-snippet-end:eSign16Step5
echo ""
echo "Response:"
cat $response
echo ""

signing_url=`cat $response | grep url | sed 's/.*\"url\":\"//' | sed 's/\".*//'`


echo ""
printf "The embedded signing URL is ${signing_url}\n"
printf "It is only valid for five minutes. Attempting to automatically open your browser...\n"
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
rm "$doc1_base64"

echo ""
echo ""
echo "Done."
echo ""
