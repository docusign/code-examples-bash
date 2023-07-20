#!/bin/bash
# Shared access
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

ds_access_token_path="config/ds_access_token.txt"
api_account_id_path="config/API_ACCOUNT_ID"

if [ ! -f $ds_access_token_path ]; then
    ds_access_token_path="../config/ds_access_token.txt"
    api_account_id_path="../config/API_ACCOUNT_ID"
fi

# Step 1: Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat ${ds_access_token_path})

# Set up variables for full code example
# Note: Substitute these values with your own
ACCOUNT_ID=$(cat ${api_account_id_path})


base_path="https://demo.docusign.net/restapi"

# Construct your API headers
#ds-snippet-start:eSign43Step2
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")
#ds-snippet-end:eSign43Step2

# temp files:
request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)

Status=$(curl --request GET https://account-d.docusign.com/oauth/userinfo \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})

IMPERSONATION_USER_GUID=`cat $response | grep sub | sed 's/.*\"sub\":\"//' | sed 's/\",.*//'`
echo ""
cat $IMPERSONATION_USER_GUID

rm "$request_data"
rm "$response"

request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)
echo "Please enter the name of the new agent: "
read AGENT_NAME
echo "Please enter the email address of the new agent: "
read AGENT_EMAIL
echo "Please input an activation code for the new agent. Save this code. You'll need it when activating the new agent."
read ACTIVATION

# Create a new agent in the account
#ds-snippet-start:eSign43Step3
printf \
'{
  "newUsers": [
    {
      "activationAccessCode": "'"${ACTIVATION}"'",
      "userName": "'"${AGENT_NAME}"'",
      "email": "'"${AGENT_EMAIL}"'"
    }
  ]
}' >> $request_data

Status=$(curl --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/users \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})

echo ""
echo "Response: "
cat $response
echo ""

AGENT_USER_ID=`cat $response | grep userId | sed 's/.*\"userId\":\"//' | sed 's/\",.*//'`
#ds-snippet-end:eSign43Step3

echo "" 
echo "Agent has been created. Please go to the agent's email to activate the agent, and press 1 to continue the example: "
read choice

if [ "$choice" != "1" ]; then 
echo "Closing the example... "
exit 0

else
rm "$request_data"
rm "$response"

# Sharing the envelope with the agent

request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)

# Construct the request body
#ds-snippet-start:eSign43Step4
printf \
'{
    "agentUser":
        {
            "userId": "'"${AGENT_USER_ID}"'",
            "accountId": "'"${ACCOUNT_ID}"'"
        },
    "permission": "manage"
}' >> $request_data

Status=$(curl --request POST ${base_path}/v2.1/accounts/${ACCOUNT_ID}/users/${IMPERSONATION_USER_GUID}/authorization \
"${Headers[@]}" \
--data-binary @${request_data} \
--output ${response})
#ds-snippet-end:eSign43Step4

echo ""
cat $response
echo ""
rm "$request_data"
rm "$response"

# Principal is told to log out and log in as the new agent
echo "" 
echo "Please go to the principal's developer account at admindemo.docusign.com and log out, then come back to this terminal. Press 1 to continue: "
read choice

if [ "$choice" != "1" ]; then 
echo "Closing the example... "
exit 0

else
source ./examples/eSignature/lib/utils.sh
SharedAccessLogin

# Make the API call to check the envelope

#ds-snippet-start:eSign43Step5
response=$(mktemp /tmp/response-bs.XXXXXX)

if date -v -10d &> /dev/null ; then
    # Mac
    from_date=`date -v -10d '+%Y-%m-%dT%H:%M:%S%z'`
else
    # Not a Mac
    from_date=`date --date='-10 days' '+%Y-%m-%dT%H:%M:%S%z'`

curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "X-DocuSign-Act-On-Behalf: ${IMPERSONATION_USER_GUID}" \
     --header "Content-Type: application/json" \
     --get \
     --output $response \
     --data-urlencode "from_date=${from_date}" \
     --request GET ${base_path}/v2.1/accounts/${ACCOUNT_ID}/envelopes/
#ds-snippet-end:eSign43Step5

echo ""

if [[ -z "$response" ]]; then  
    echo "Response body is empty because there are no envelopes in the account. Please run example 2 and re-run this example." 
else
    echo ""
    cat $response

# cleanup
rm "$response"

echo ""
echo "Done."

fi
fi
fi
fi