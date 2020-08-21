# Send an envelope including an order form with payment by credit card
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi



# Configuration
# 1. Search for and update '{USER_EMAIL}' and '{USER_FULLNAME}'.
#    They occur and re-occur multiple times below.
# 2. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)
# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

# 4. Log in to DocuSign Admin and from the top 
#    navigation, select Admin. From there look 
#    to the left under INTEGRATIONS and select 
#    Payments to retrieve your Gateway account ID. 

base_path="https://demo.docusign.net/restapi"

# temp files:
request_data=$(mktemp /tmp/request-eg-014.XXXXXX)
response=$(mktemp /tmp/response-eg-014.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-014-doc1.XXXXXX)

# ***DS.snippet.0.start
# Fetch doc and encode
cat demo_documents/order_form.html | base64 > $doc1_base64

echo ""
echo "Sending the envelope request to DocuSign..."

# Concatenate the different parts of the request
printf \
'{
    "emailSubject": "Please complete your order",
    "documents": [
        {
            "documentBase64": "' > $request_data
            cat $doc1_base64 >> $request_data
            printf '",
            "name": "Order form", "fileExtension": "html",
            "documentId": "1"
        }
    ],
    "recipients": {
        "carbonCopies": [
            {
                "email": "'${CC_EMAIL}'", "name": "'"${CC_NAME}"'",
                "recipientId": "2", "routingOrder": "2"
            }
        ],
        "signers": [
            {
                "email": "'${SIGNER_EMAIL}'", "name": "'"${SIGNER_NAME}"'",
                "recipientId": "1", "routingOrder": "1",
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
                            "anchorXOffset": "50", "anchorYOffset": "-8",
                            "bold": "true", "disableAutoSize": "false",
                            "font": "helvetica", "fontSize": "size12",
                            "formula": "[l1e] + [l2e]", "locked": "true",
                            "required": "true", "roundDecimalPlaces": "0",
                            "tabLabel": "l3t"
                        },
                        {
                            "documentId": "1", "formula": "([l1e] + [l2e]) * 100",
                            "hidden": "true", "locked": "true",
                            "pageNumber": "1",
                            "paymentDetails": {
                                "currencyCode": "USD",
                                "gatewayAccountId": "' >> $request_data
                                printf "${GATEWAY_ACCOUNT_ID}" >> $request_data
                                printf '",
                                "gatewayDisplayName": "Stripe",
                                "gatewayName": "stripe",
                                "lineItems": [
                                    {
                                        "amountReference": "l1e",
                                        "description": "$5 each",
                                        "name": "Harmonica"
                                    },
                                    {
                                        "amountReference": "l2e",
                                        "description": "$150 each",
                                        "name": "Xylophone"
                                    }
                                ]
                            },
                            "required": "true", "roundDecimalPlaces": "0",
                            "tabLabel": "payment",
                            "xPosition": "0", "yPosition": "0"
                        }
                    ],
                    "listTabs": [
                        {
                            "anchorString": "/l1q/", "anchorUnits": "pixels",
                            "anchorXOffset": "0", "anchorYOffset": "-10",
                            "font": "helvetica", "fontSize": "size11",
                            "listItems": [
                                {"text": "none", "value": "0"},
                                {"text": "1", "value": "1"},
                                {"text": "2","value": "2"},
                                {"text": "3","value": "3"},
                                {"text": "4","value": "4"},
                                {"text": "5","value": "5"},
                                {"text": "6","value": "6"},
                                {"text": "7","value": "7"},
                                {"text": "8","value": "8"},
                                {"text": "9","value": "9"},
                                {"text": "10","value": "10"}
                            ],
                            "required": "true", "tabLabel": "l1q"
                        },
                        {
                            "anchorString": "/l2q/", "anchorUnits": "pixels",
                            "anchorXOffset": "0", "anchorYOffset": "-10",
                            "font": "helvetica", "fontSize": "size11",
                            "listItems": [
                                {"text": "none", "value": "0"},
                                {"text": "1", "value": "1"},
                                {"text": "2", "value": "2"},
                                {"text": "3", "value": "3"},
                                {"text": "4", "value": "4"},
                                {"text": "5", "value": "5"},
                                {"text": "6", "value": "6"},
                                {"text": "7", "value": "7"},
                                {"text": "8", "value": "8"},
                                {"text": "9", "value": "9"},
                                {"text": "10", "value": "10"}
                            ],
                            "required": "true", "tabLabel": "l2q"
                        }
                    ],
                    "signHereTabs": [
                        {
                            "anchorString": "/sn1/", "anchorUnits": "pixels",
                            "anchorXOffset": "20", "anchorYOffset": "10"
                        }
                    ]
                }
            }
        ]
    },
    "status": "sent"
}' >> $request_data

curl --header "Authorization: Bearer ${access_token}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path}/v2.1/accounts/${account_id}/envelopes \
     --output $response
# ***DS.snippet.0.end

echo ""
echo "Results:"
echo ""
cat $response

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo ""
echo "Done."
echo ""

