# Use embedded signing
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

base_path="https://demo.docusign.net/restapi"

# temp files:
request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
response=$(mktemp /tmp/response-eg-001.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-001-doc1.XXXXXX)

# Fetch doc and encode
cat demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc1_base64

# Get the email address of the current account

curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request GET https://account-d.docusign.com/oauth/userinfo \
     --output ${response}

HOST_EMAIL=`cat $response | grep email | sed 's/.*\"email\":\"//' | sed 's/\",.*//'`
HOST_NAME=`cat $response | grep name | sed 's/.*\"name\":\"//' | sed 's/\",.*//'`

read -p "Please enter the name of the in person signer: " IN_PERSON_SIGNER_NAME

echo ""
echo "Sending the envelope request to DocuSign..."

# Step 2 start
printf \
'{
    "emailSubject": "Please host this in-person signing session",
    "documents": [
        {
            "documentBase64": "' > $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf",
            "documentId": "1"
        }
    ],
    "recipients": {
        "inPersonSigners": [
            {
                "hostEmail": "'"${HOST_EMAIL}"'",
                "hostName": "'"${HOST_NAME}"'",
                "signerName": "'"${IN_PERSON_SIGNER_NAME}"'",
                "recipientId": "1",
                "routingOrder": "1",
                "tabs": {
                    "signHereTabs": [
                        {
                            "anchorString": "/sn1/",
                            "anchorUnits": "pixels",
                            "anchorXOffset": "20",
                            "anchorYOffset": "10"
                        }
                    ]
                }
            }
        ]
    },
    "status": "sent"
}' >> $request_data
# Step 2 end

# Step 3 start
curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output ${response}

echo ""
echo "Response:" `cat $response`
echo ""

# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`
echo "EnvelopeId: ${envelope_id}"
# Step 3 end

# Create a recipient view (an embedded signing view) that the host will open to initiate in person signing
#
# The returnUrl is normally your own web app. DocuSign will redirect
# the signer to returnUrl when the DocuSign signing completes.
# For this example, we'll use http://httpbin.org/get to show the
# query parameters passed back from DocuSign

# temp files:
request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
response=$(mktemp /tmp/response-eg-001.XXXXXX)

# Step 4 start
printf \
'{
    "returnUrl": "http://httpbin.org/get",
    "authenticationMethod": "none",
    "email": "'"${HOST_EMAIL}"'",
    "userName": "'"${HOST_NAME}"'"
}' >> $request_data
# Step 4 end

# Create the recipient view and call the API to initiate the signing

echo ""
echo "Requesting the url for the embedded signing..."
echo ""

# Step 5 start
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
# Step 5 end
echo ""
echo "The embedded signing URL is ${signing_url}"
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
rm "$doc1_base64"

echo ""
echo "Done."
