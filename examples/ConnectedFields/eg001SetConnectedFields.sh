# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

ds_access_token_path="config/ds_access_token.txt"
verification_file="config/verification_app.txt"

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat ${ds_access_token_path})

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)
base_path="https://api-d.docusign.com/v1"

#ds-snippet-start:ConnectedFields1Step2
#apx-snippet-start:ConnectedFieldsApi_GetTabGroups
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
            '--header' "Accept: application/json" \
			'--header' "Content-Type: application/json")
#ds-snippet-end:ConnectedFields1Step2

#ds-snippet-start:ConnectedFields1Step3
response=$(mktemp ./response-cf.XXXXXX)
Status=$(curl -w '%{http_code}' -i --ssl-no-revoke --request GET https://api-d.docusign.com/v1/accounts/${account_id}/connected-fields/tab-groups \
    "${Headers[@]}" \
    --output ${response})
#ds-snippet-end:ConnectedFields1Step3
#apx-snippet-end:ConnectedFieldsApi_GetTabGroups

echo ""
echo "Response:"
cat $response
echo ""

invoke_python() {
    if [[ $(python3 --version 2>&1) == *"not found"* ]]; then
        if [[ $(python --version 2>&1) != *"not found"* ]]; then
            python -c "from examples.ConnectedFields.jsonParsingUtils import *; from json import *; print($1)"
        else
            echo "Either python or python3 must be installed to use this option."
            exit 1
        fi
    else
        python3 -c "from examples.ConnectedFields.jsonParsingUtils import *; from json import *; print($1)"
    fi
}

#Extract tab data from response
#ds-snippet-start:ConnectedFields1Step4
extract_verify_info() {
    invoke_python "filter_by_verify_action('''$response''')"
}

prompt_user_choice() {
    local json_data="'''$1'''"
    unique_apps=()
    while IFS= read -r line; do
        unique_apps+=("$line")
    done < <(invoke_python "extract_unique_apps($json_data)")

    if [[ -z "$json_data" || "$json_data" == "[]" ]]; then
        echo "No data verification were found in the account. Please install a data verification app."
        echo ""
        echo "You can install a phone number verification extension app by copying the following link to your browser: "
        echo "https://apps.docusign.com/app-center/app/d16f398f-8b9a-4f94-b37c-af6f9c910c04"
        exit 1
    fi

    echo "Please select an app by entering a number:"
    for i in "${!unique_apps[@]}"; do
        echo "$((i+1)). ${unique_apps[$i]#* }"
    done

    read -p "Enter choice (1-${#unique_apps[@]}): " choice
    if [[ "$choice" =~ ^[1-${#unique_apps[@]}]$ ]]; then
        chosen_app_id="'${unique_apps[$((choice-1))]%% *}'"
        selected_data=$(invoke_python "filter_by_app_id('''$response''', $chosen_app_id)")
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
}

if [[ -z "$response" ]]; then
    echo "Error: response file variable not set."
    exit 1
fi

filtered_data=$(extract_verify_info)

if [[ -z "$filtered_data" || "$filtered_data" == "[]" ]]; then
    echo "No data verification were found in the account. Please install a data verification app."
    echo ""
    echo "You can install a phone number verification extension app by copying the following link to your browser: "
    echo "https://apps.docusign.com/app-center/app/d16f398f-8b9a-4f94-b37c-af6f9c910c04"
    exit 1
fi

prompt_user_choice "$filtered_data"
#ds-snippet-end:ConnectedFields1Step4

request_data=$(mktemp /tmp/request-eg-001.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-001-doc1.XXXXXX)
cat demo_documents/World_Wide_Corp_lorem.pdf | base64 > $doc1_base64

#Construct the request body
#ds-snippet-start:ConnectedFields1Step5
text_tabs=$(invoke_python "make_text_tabs_list('''$selected_data''', $chosen_app_id)")

printf \
'{
    "emailSubject": "Please sign this document",
    "documents": [
        {
            "documentBase64": "' > "$request_data"
            cat $doc1_base64 >> $request_data
            printf '",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf",
            "documentId": "1"
        }
    ],
    "status": "sent",
    "recipients": {
        "signers": [
            {
                "email": "'"${SIGNER_EMAIL}"'",
                "name": "'"${SIGNER_NAME}"'",
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
                    ],
                    "textTabs": ' >> "$request_data"
                        printf '%s' "$text_tabs" >> "$request_data"  # Ensure all tabs are added
                        printf '
                }
            }
        ]
    }
}' >> $request_data
#ds-snippet-end:ConnectedFields1Step5

# Remove the temporary file
rm "$response"

echo ""
echo ""
echo "Done."
echo ""

#ds-snippet-start:ConnectedFields1Step6
response=$(mktemp /tmp/response-eg-001.XXXXXX)

echo ""
echo "Sending the envelope request to Docusign..."


base_path2="https://demo.docusign.net/restapi"

curl --header "Authorization: Bearer ${ACCESS_TOKEN}" \
     --header "Content-Type: application/json" \
     --data-binary @${request_data} \
     --request POST ${base_path2}/v2.1/accounts/${account_id}/envelopes \
     --output $response

echo ""
echo "Response:"
cat $response
echo ""
#ds-snippet-end:ConnectedFields1Step6

# pull out the envelopeId
envelope_id=`cat $response | grep envelopeId | sed 's/.*\"envelopeId\":\"//' | sed 's/\",.*//'`

# Save the envelope id for use by other scripts
echo "EnvelopeId: ${envelope_id}"
echo ${envelope_id} > config/ENVELOPE_ID

# cleanup
rm "$request_data"
rm "$response"
rm "$doc1_base64"

echo ""
echo ""
echo "Done. When signing the envelope, ensure the connection to your data verification extension app is active."
echo ""