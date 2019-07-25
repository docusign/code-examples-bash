# Embedded signing ceremony
#
# This script changes a remote signer (email signer) to an embedded
# signer and then gets the signing ceremony url.
#
# When the signer is changed, the envelope no longer appears in the 
# signers DocuSign tool. This can be fixed by adding the signer
# as a cc also.
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Configuration
# 1. Obtain an OAuth access token from 
#    https://developers.docusign.com/oauth-token-generator
access_token='{ACCESS_TOKEN}'
# 2. Obtain your accountId from demo.docusign.com -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or 
#    the default picture. 
account_id='{ACCOUNT_ID}'
# envelope id
envelope_id='xxx'
#
# You also need to fill in the recipient_id, name, and email below
#

base_path="https://demo.docusign.net/restapi"
# temp files:
response=$(mktemp /tmp/response-eg-001.XXXXXX)

# Step 1: change the remote signer to an embedded signer
# See https://developers.docusign.com/esign-rest-api/reference/Envelopes/EnvelopeRecipients/update
# You can add a clientUserId attribute to a sent envelope...
# NOTE: recipientId is from the existing envelope
echo ""
echo "Changing a remote signer to embedded..."
curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --data-binary '
{
    signers: [
        {
           "clientUserId": "1000",
           "email": "{USER_EMAIL}",
           "name": "{USER_FULLNAME}",
           "recipientId": "{RECIPIENT_ID}"
        }
    ]
}' \
     --request PUT ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/recipients \
     --output ${response}

echo ""
echo "Response:"
cat $response

# Step 2. Create a recipient view (a signing ceremony view)
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
    "userName": "{USER_FULLNAME}",
    "clientUserId": 1000,
}' \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes/${envelope_id}/views/recipient \
     --output ${response}

echo ""
echo "Response:"
cat $response
echo ""

signing_ceremony_url=`cat $response | grep url | sed 's/.*\"url\": \"//' | sed 's/\".*//'`
# ***DS.snippet.0.end
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
rm "$response"

echo ""
echo ""
echo "Done."
echo ""


