# Set Template-based Envelope Tab Data


# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
oAuthAccessToken="{ACCESS_TOKEN}"

#Set up variables for full code example
# Note: Substitute these values with your own
APIAccountId="{ACCOUNT_ID}"

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

base_path="https://demo.docusign.net/restapi"


# temp files:
request_data=$(mktemp /tmp/request-eg-017.XXXXXX)
response=$(mktemp /tmp/response-eg-017.XXXXXX)

# Check that we have a template id
if [ ! -f ../TEMPLATE_ID ]; then
    echo ""
    echo "PROBLEM: An template id is needed. Fix: execute script eg008CreateTemplate.sh"
    echo ""
    exit -1
fi
template_id=`cat ../TEMPLATE_ID`

response=$(mktemp /tmp/response-eg-017.XXXXXX)

echo ""
echo "Sending the envelope request to DocuSign..."

# Step 2. Construct the JSON body for your envelope
printf \
'{
    "customFields": {
        "textCustomFields": [{
            "name": "app metadata item",
            "required": "false",
            "show": "true",
            "value": "1234567"
        }]
    },
    "status": "Sent",
    "templateId": "'${template_id}'",
    "templateRoles": [{
        "clientUserId": "1000",
        "email": "{USER_EMAIL}",
        "name": "{USER_NAME}",
        "roleName": "signer",
        "tabs": {
            "checkboxTabs": [{
                "selected": "true",
                "tabLabel": "ckAuthorization"
            }, {
                "selected": "true",
                "tabLabel": "ckAgreement"
            }],
            "listTabs": [{
                "documentId": "1",
                "pageNumber": "1",
                "tabLabel": "list",
                "value": "green"
            }],
            "radioGroupTabs": [{
                "groupName": "radio1",
                "radios": [{
                    "selected": "true",
                    "value": "white"
                }]
            }],
            "textTabs": [{
                "tabLabel": "text",
                "value": "Jabberywocky!"
            }, {
                "bold": "true",
                "documentId": "1",
                "font": "helvetica",
                "fontSize": "size14",
                "height": "23",
                "locked": "false",
                "pageNumber": "1",
                "required": "false",
                "tabId": "name",
                "tabLabel": "added text field",
                "value": "{USER_NAME}",
                "width": "84",
                "xPosition": "280",
                "yPosition": "172"
            }]
        }
    }, {
        "email": "{CC_EMAIL}",
        "name": "{CC_NAME}",
        "roleName": "cc"
    }]
}' >> $request_data
#Step 2: a) Create your authorization headers
#        b) Send a POST request to the Envelopes endpoint

curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output ${response}

echo ""
echo "Response:"
cat $response
echo ""

# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":"//' | sed 's/\",.*//'` 
echo ""

echo "EnvelopeId: ${envelope_id}"


# Step 3. Create a recipient view (a signing ceremony view)
#         that the signer will directly open in their browser to sign.
#
# The returnUrl is normally your own web app. DocuSign will redirect
# the signer to returnUrl when the signing ceremony completes.
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
    "email": "{USER_EMAIL}",
    "userName": "{USER_NAME}",
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
printf "It is only valid for a couple of minutes. Attempting to automatically open your browser...\n"
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

echo ""
echo ""
echo "Done."
echo ""

