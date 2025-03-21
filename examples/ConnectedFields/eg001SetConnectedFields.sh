# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing jq..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt-get update && sudo apt-get install -y jq  # For Debian/Ubuntu
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq  # For macOS (Homebrew)
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
        echo "Please install jq manually from: https://stedolan.github.io/jq/download/"
        exit 1
    else
        echo "Unsupported OS. Please install jq manually."
        exit 1
    fi
else
    echo "jq is already installed."
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
declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
            '--header' "Accept: application/json" \
			'--header' "Content-Type: application/json")
#ds-snippet-end:ConnectedFields1Step2

#ds-snippet-start:ConnectedFields1Step3
response=$(mktemp /tmp/response-cf.XXXXXX)
Status=$(curl -w '%{http_code}' -i --ssl-no-revoke --request GET https://api-d.docusign.com/v1/accounts/${account_id}/connected-fields/tab-groups \
    "${Headers[@]}" \
    --output ${response})
#ds-snippet-end:ConnectedFields1Step3

echo ""
echo "Response:"
cat $response
echo ""

#Extract tab data from response
#ds-snippet-start:ConnectedFields1Step4
extract_verify_info() {
    clean_response=$(sed -n '/\[/,$p' "$response")
    echo "$clean_response" | jq '[.[] | select((.tabs[]?.extensionData.actionContract | contains("Verify")) or (.tabs[]?.tabLabel? // empty | contains("connecteddata")))]'
}

prompt_user_choice() {
    local json_data="$1"
    mapfile -t unique_apps < <(echo "$json_data" | jq -r '[.[] | {appId: .appId, applicationName: .tabs[0].extensionData.applicationName}] | unique_by(.appId) | .[] | "\(.appId) \(.applicationName)"')

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
        chosen_app_id="${unique_apps[$((choice-1))]%% *}"
        selected_data=$(echo "$json_data" | jq --arg appId "$chosen_app_id" '[.[] | select(.appId == $appId)]')
        parse_verification_data "$selected_data"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
}

parse_verification_data() {
    local clean_json="$1"
    
    app_id=$(echo "$clean_json" | jq -r '.[0].appId')
    extension_group_id=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.extensionGroupId')
    publisher_name=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.publisherName')
    application_name=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.applicationName')
    action_name=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.actionName')
    action_input_key=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.actionInputKey')
    action_contract=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.actionContract')
    extension_name=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.extensionName')
    extension_contract=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.extensionContract')
    required_for_extension=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.requiredForExtension')
    tab_label=$(echo "$clean_json" | jq -r '.[0].tabs[].tabLabel')
    connection_key=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.connectionInstances[0].connectionKey')
    connection_value=$(echo "$clean_json" | jq -r '.[0].tabs[0].extensionData.connectionInstances[0].connectionValue')
    
    echo "App ID: $app_id"
    echo "Extension Group ID: $extension_group_id"
    echo "Publisher Name: $publisher_name"
    echo "Application Name: $application_name"
    echo "Action Name: $action_name"
    echo "Action Contract: $action_contract"
    echo "Action Input Key: $action_input_key"
    echo "Extension Name: $extension_name"
    echo "Extension Contract: $extension_contract"
    echo "Required for Extension: $required_for_extension"
    echo "Tab Label: $tab_label"
    echo "Connection Key: $connection_key"
    echo "Connection Value: $connection_value"
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
#ds-snippet-start:eConnectedFields1Step5
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
                    "textTabs": [
                        {
                            "requireInitialOnSharedChange": false,
                            "requireAll": false,
                            "name": "'"${application_name}"'",
                            "required": true,
                            "locked": false,
                            "disableAutoSize": false,
                            "maxLength": 4000,
                            "tabLabel": "'"${tab_label}"'",
                            "font": "lucidaconsole",
                            "fontColor": "black",
                            "fontSize": "size9",
                            "documentId": "1",
                            "recipientId": "1",
                            "pageNumber": "1",
                            "xPosition": "273",
                            "yPosition": "191",
                            "width": "84",
                            "height": "22",
                            "templateRequired": false,
                            "tabType": "text",
                            "extensionData": {
                                "extensionGroupId": "'"${extension_group_id}"'",
                                "publisherName": "'"${publisher_name}"'",
                                "applicationId": "'"${app_id}"'",
                                "applicationName": "'"${application_name}"'",
                                "actionName": "'"${action_name}"'",
                                "actionContract": "'"${action_contract}"'",
                                "extensionName": "'"${extension_name}"'",
                                "extensionContract": "'"${extension_contract}"'",
                                "requiredForExtension": "'"${required_for_extension}"'",
                                "actionInputKey": "'"${action_input_key}"'",
                                "extensionPolicy": "None",
                                "connectionInstances": [
                                    {
                                        "connectionKey": "'"${connection_key}"'",
                                        "connectionValue": "'"${connection_value}"'"
                                    }
                                ]
                            }
                        }
                    ]
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