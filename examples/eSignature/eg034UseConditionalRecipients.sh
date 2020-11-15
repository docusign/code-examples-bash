# How to use conditional recipients
# https://developers.docusign.com/docs/esign-rest-api/how-to/use-conditional-recipients/

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# SIGNER_NOT_CHECKED_NAME
# SIGNER_NOT_CHECKED_EMAIL
# SIGNER_WHEN_CHECKED_NAME
# SIGNER_WHEN_CHECKED_EMAIL
# SIGNER1_NAME
# SIGNER1_EMAIL

# Step 1: Create your API Headers
# Note: These values are not valid, but are shown for example purposes only!
access_token=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://demo.docusign.net/restapi"

# Step 2. Construct your API headers
# Construct your API headers
declare -a Headers=('--header' "Authorization: Bearer $access_token"
    '--header' "Accept: application/json"
    '--header' "Content-Type: application/json")

# Step 3. Construct the request body

# Create a temporary files to store the JSON body and response
request_data=$(mktemp /tmp/request-bs.XXXXXX)
response=$(mktemp /tmp/response-bs.XXXXXX)

printf \
    '{
  "documents": 
  [
    {
      "documentBase64": "VGhhbmtzIGZvciByZXZpZXdpbmcgdGhpcyEKCldlJ2xsIG1vdmUgZm9yd2FyZCBhcyBzb29uIGFzIHdlIGhlYXIgYmFjay4=",
      "documentId": "1",
      "fileExtension": "txt",
      "name": "Welcome"
    }
  ],
  "emailSubject": "ApproveIfChecked",
  "workflow": 
  {
  "workflowSteps": 
  [
    {
   "action": "pause_before",
    "triggerOnItem": "routing_order",
    "itemId": 2,
    "status": "pending",
    "recipientRouting": 
      {
        "rules": 
        {
          "conditionalRecipients": 
          [
            {
            "recipientId": 2,
            "order": "0",
            "recipientGroup": 
              {
                "groupName": "Approver",
                "groupMessage": "Members of this group approve a workflow",
                "recipients": 
                [
                  {
                    "recipientLabel": "signer2a",
                    "name": "'"${SIGNER_NOT_CHECKED_NAME}"'",
                    "roleName": "Signer when not checked",
                    "email": "'"${SIGNER_NOT_CHECKED_EMAIL}"'"
                  },
                  {
                    "recipientLabel": "signer2b",
                    "name": "'"${SIGNER_WHEN_CHECKED_NAME}"'",
                    "roleName": "Signer when checked",
                    "email": "'"${SIGNER_WHEN_CHECKED_EMAIL}"'"
                  }
                ]
              },
              "conditions": 
              [
                {
                  "recipientLabel": "signer2a",
                  "order": 1,
                  "filters": 
                  [
                    {
                      "scope": "tabs",
                      "recipientId": "1",
                      "tabId": "ApprovalTab",                      
                      "operator": "equals",
                      "value": "false",
                      "tabLabel": "ApproveWhenChecked"
                    }
                  ]
                },
                {
                  "recipientLabel": "signer2b",
                  "order": 2,
                  "filters": 
                  [
                    {
                      "scope": "tabs",
                      "recipientId": "1",
                      "tabId": "ApprovalTab",
                      "operator": "equals",
                      "value": "true",
                      "tabLabel": "ApproveWhenChecked"
                    }
                  ]
                }
              ]
            }
          ]
        }
      }
    }
    ]
  },
  "recipients": 
  {
    "signers": 
    [
      {
        "email": "'"${SIGNER1_EMAIL}"'",
        "name": "'"${SIGNER1_NAME}"'",
        "recipientId": "1",
        "routingOrder": "1",
        "roleName": "Purchaser",
        "tabs": 
        {
          "signHereTabs": 
          [
            {
              "name": "SignHere",
              "documentId": "1",
              "pageNumber": "1",
              "tabLabel": "PurchaserSignature",
              "xPosition": "200",
              "yPosition": "200"
            }
          ]
          ,
          "checkboxTabs":
          [
            {
              "name": "ClickToApprove",
              "selected": "false",
              "documentId": "1",
              "pageNumber": "1",
              "tabLabel": "ApproveWhenChecked",
              "xPosition": "50",
              "yPosition": "50"
            }
          ]
        }
      },
      {
        "email": "placeholder@example.com",
        "name": "Approver",
        "recipientId": "2",
        "routingOrder": "2",
        "roleName" : "Approver",
        "tabs": 
        {
          "signHereTabs": 
          [
            {
              "name": "SignHere",
              "documentId": "1",
              "pageNumber": "1",
              "recipientId": "2",
              "tabLabel": "ApproverSignature",
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
    exit 1
fi

echo ""
echo "Request:"
cat $request_data
echo ""

# Check the response
echo ""
echo $(cat $response)
echo ""

# Remove the temporary files
rm "$response"
rm "$request_data"
