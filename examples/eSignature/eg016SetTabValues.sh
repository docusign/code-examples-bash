# Set Envelope Tab Data

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
access_token=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# Temp files:
request_data=$(mktemp /tmp/request-eg-016.XXXXXX)
response=$(mktemp /tmp/response-eg-016.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-016-doc1.XXXXXX)

echo ""
echo "Sending the envelope request to DocuSign..."

# Fetch doc and encode
cat demo_documents/World_Wide_Corp_salary.docx | base64 > $doc1_base64

# Step 2. Construct the JSON body for your envelope
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
                }, {
                    "anchorString": "/salary/",
                    "anchorUnits": "pixels",
                    "anchorXOffset": "5",
                    "anchorYOffset": "-9",
                    "bold": "true",
                    "font": "helvetica",
                    "fontSize": "size11",
                    "locked": "true",
                    "tabId": "salary",
                    "tabLabel": "Salary",
                    "value": "$123,000.00"
                }]
            }
        }]
    },
    "status": "Sent"
}' >> $request_data
# Step 3: a) Create your authorization headers
#         b) Send a POST request to the Envelopes endpoint

curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output ${response}

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


# Step 4. Create a recipient view (a signing ceremony view)
#         that the signer will directly open in their browser to sign
#
# The return URL is normally your own web app. DocuSign will redirect
# the signer to the return URL when the signing ceremony completes.
# For this example, we'll use http://httpbin.org/get to show the 
# query parameters passed back from DocuSign

echo ""
echo "Requesting the url for the signing ceremony..."
curl --header "Authorization: Bearer ${access_token}" \
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

echo ""
echo "Response:"
cat $response
echo ""

signing_ceremony_url=`cat $response | grep url | sed 's/.*\"url\":\"//'# | sed 's/\".*//'`


echo ""
printf "The signing ceremony URL is ${signing_ceremony_url}\n"
printf "It is only valid for five minutes. Attempting to automatically open your browser...\n"
if which xdg-open &> /dev/null  ; then
  xdg-open "$signing_ceremony_url"
elif which open &> /dev/null    ; then
  open "$signing_ceremony_url"
elif which start &> /dev/null   ; then
  start "$signing_ceremony_url"
fi

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo ""
echo "Done."
echo ""