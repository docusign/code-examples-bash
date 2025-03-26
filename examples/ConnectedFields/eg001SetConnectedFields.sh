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
    clean_response=$(sed -n '/\[/,$p' "$response")
    invoke_python "filter_by_verify_action('''$clean_response''')"
}

prompt_user_choice() {
    local json_data="'''$1'''"
    mapfile -t unique_apps < <(invoke_python "extract_unique_apps($json_data)")

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
        selected_data=$(invoke_python "filter_by_app_id($json_data, $chosen_app_id)")
        parse_verification_data "$selected_data"
    else
        echo "Invalid choice. Exiting."
        exit 1
    fi
}

parse_verification_data() {
    local clean_json="'''$1'''"
    
    app_id=$(echo "$clean_json" | invoke_python "get_app_id($clean_json)")
    extension_group_id=$(echo "$clean_json" | invoke_python "get_extension_group_id($clean_json)")
    publisher_name=$(echo "$clean_json" | invoke_python "get_publisher_name($clean_json)")
    application_name=$(echo "$clean_json" | invoke_python "get_application_name($clean_json)")
    action_name=$(echo "$clean_json" | invoke_python "get_action_name($clean_json)")
    action_input_key=$(echo "$clean_json" | invoke_python "get_action_input_key($clean_json)")
    action_contract=$(echo "$clean_json" | invoke_python "get_action_contract($clean_json)")
    extension_name=$(echo "$clean_json" | invoke_python "get_extension_name($clean_json)")
    extension_contract=$(echo "$clean_json" | invoke_python "get_extension_contract($clean_json)")
    required_for_extension=$(echo "$clean_json" | invoke_python "get_required_for_extension($clean_json)")
    tab_label=$(echo "$clean_json" | invoke_python "get_tab_label($clean_json)")
    connection_key=$(echo "$clean_json" | invoke_python "get_connection_key($clean_json)")
    connection_value=$(echo "$clean_json" | invoke_python "get_connection_value($clean_json)")
        
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
#ds-snippet-start:ConnectedFields1Step5
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