# Set Template-based Envelope Tab Data

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

base_path="https://demo.docusign.net/restapi"

# Construct your API headers
#ds-snippet-start:eSign17Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
					'--header' "Accept: application/json" \
					'--header' "Content-Type: application/json")
#ds-snippet-end:eSign17Step2

# temp files:
request_data=$(mktemp /tmp/request-eg-017.XXXXXX)
response=$(mktemp /tmp/response-eg-017.XXXXXX)

# Check that we have a template ID
if [ ! -f config/TEMPLATE_ID ]; then
    echo ""
    echo "PROBLEM: A templateId is needed. Fix: execute script eg008CreateTemplate.sh"
    echo ""
    exit 0
fi
template_id=`cat config/TEMPLATE_ID`

response=$(mktemp /tmp/response-eg-017.XXXXXX)

echo ""
echo "Sending the envelope request to DocuSign..."

#ds-snippet-start:eSign17Step3
declare -A text_custom_fields
text_custom_fields["name"]="app metadata item"
text_custom_fields["required"]="false"
text_custom_fields["show"]="true"
text_custom_fields["value"]="1234567"

declare -A checkbox_tabs
checkbox_tabs["selected1"]="true"
checkbox_tabs["tabLabel1"]="ckAuthorization"
checkbox_tabs["selected2"]="true"
checkbox_tabs["tabLabel2"]="ckAgreement"

declare -A list_tabs
list_tabs["documentId"]="1"
list_tabs["pageNumber"]="1"
list_tabs["tabLabel"]="list"
list_tabs["value"]="green"

declare -A radio_tabs
radio_tabs["selected"]="true"
radio_tabs["value"]="white"

declare -A text_tabs
text_tabs["tabLabel"]="text"
text_tabs["value"]="Jabberywocky!"
#ds-snippet-end:eSign17Step3

# Construct the JSON body for your envelope
#ds-snippet-start:eSign17Step4
printf \
'{
    "customFields": {
        "textCustomFields": [{
            "name": "'"${text_custom_fields["name"]}"'",
            "required": "'"${text_custom_fields["required"]}"'",
            "show": "'"${text_custom_fields["show"]}"'",
            "value": "'"${text_custom_fields["value"]}"'"
        }]
    },
    "status": "Sent",
    "templateId": "'"${template_id}"'",
    "templateRoles": [{
        "clientUserId": "1000",
        "email": "'"${SIGNER_EMAIL}"'",
        "name": "'"${SIGNER_NAME}"'",
        "roleName": "signer",
        "tabs": {
            "checkboxTabs": [{
                "selected": "'"${checkbox_tabs["selected1"]}"'",
                "tabLabel": "'"${checkbox_tabs["tabLabel1"]}"'"
            }, {
                "selected": "'"${checkbox_tabs["selected2"]}"'",
                "tabLabel": "'"${checkbox_tabs["tabLabel2"]}"'"
            }],
            "listTabs": [{
                "documentId": "'"${list_tabs["documentId"]}"'",
                "pageNumber": "'"${list_tabs["pageNumber"]}"'",
                "tabLabel": "'"${list_tabs["tabLabel"]}"'",
                "value": "'"${list_tabs["value"]}"'"
            }],
            "radioGroupTabs": [{
                "groupName": "radio1",
                "radios": [{
                    "selected": "'"${radio_tabs["selected"]}"'",
                    "value": "'"${radio_tabs["value"]}"'"
                }]
            }],
            "textTabs": [{
                "tabLabel": "'"${text_tabs["tabLabel"]}"'",
                "value": "'"${text_tabs["value"]}"'"
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
                "value": "'"${SIGNER_NAME}"'",
                "width": "84",
                "xPosition": "280",
                "yPosition": "172"
            }]
        }
    }, {
        "email": "'"${CC_EMAIL}"'",
        "name": "'"${CC_NAME}"'",
        "roleName": "cc"
    }]
}' >> $request_data
#ds-snippet-end:eSign17Step4

# Call the eSignature REST API
#ds-snippet-start:eSign17Step5
Status=$(curl -w '%{http_code}' -i --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     "${Headers[@]}" \
     --data-binary @${request_data} \
     --output ${response})
#ds-snippet-end:eSign17Step5
echo ""
echo "Response:"
cat $response
echo ""

# pull out the envelope ID
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":"//' | sed 's/\",.*//'` 
echo ""

echo "EnvelopeId: ${envelope_id}"


# Step 6. Create a recipient view (an embedded signing view)
#         that the signer will directly open in their browser to sign
#
# The return URL is normally your own web app. DocuSign will redirect
# the signer to the return URL when the DocuSign signing completes.
# For this example, we'll use http://httpbin.org/get to show the 
# query parameters passed back from DocuSign

echo ""
echo "Requesting the url for the embedded signing..."
#ds-snippet-start:eSign17Step6
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

#ds-snippet-end:eSign17Step6

echo ""
echo "Response:"
cat $response
echo ""

signing_url=`cat $response | grep url | sed 's/.*\"url\":\"//'# | sed 's/\".*//'`


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

echo ""
echo ""
echo "Done."
echo ""