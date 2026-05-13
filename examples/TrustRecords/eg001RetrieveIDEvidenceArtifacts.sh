#!/bin/bash

# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
  echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Obtain your OAuth token and Account ID
access_token=$(cat ../../config/ds_access_token.txt)
account_id=$(cat ../../config/API_ACCOUNT_ID)

# --- ID Input Selection ---
echo "Have you already completed one of the following: IDNow for GwG, Identity Verification, or a Maestro 'Verify Identity' step?"
read -p "(y/n): " has_completed

if [[ "$has_completed" =~ ^[Yy]$ ]]; then
    echo "-------------------------------------------------------"
    echo "NOTE: In the case of eSignature, the Recipient ID and the Record ID are the same."
    echo "-------------------------------------------------------"
    echo "Do you have an (1) Envelope ID or a (2) Record ID?"
    read -p "Enter 1 or 2: " id_type

    if [[ "$id_type" == "1" ]]; then
        echo "Please enter the Envelope ID:"
        read idv_envelope_id
        
        if [ -z "$idv_envelope_id" ]; then
            echo "Error: To retrieve the data, either an Envelope ID or Record ID is required. Please try again."
            exit 1
        fi

        echo "Retrieving Record ID from envelope recipients..."
        #ds-snippet-start:TrustRecords1Step2
        uri="https://demo.docusign.net/restapi/v2.1/accounts/${account_id}/envelopes/${idv_envelope_id}/recipients"
        declare -a Headers=('--header' "Authorization: Bearer ${access_token}" '--header' "Accept: application/json")
        
        response_file=$(mktemp /tmp/recipients.XXXXXX)
        status=$(curl -s -w "%{http_code}" --request GET "${uri}" "${Headers[@]}" --output ${response_file})
        #ds-snippet-end:TrustRecords1Step2

        if [[ "$status" -eq 200 ]]; then
            # Parsing the recipientIdGuid to use as the record_id
            record_id=$(cat $response_file | grep -o '"recipientIdGuid":"[^"]*' | sed 's/"recipientIdGuid":"//' | head -1)
            echo "Found Record ID: $record_id"
        else
            echo "Failed to retrieve recipients. Status: $status. Please try again."
            exit 1
        fi
    elif [[ "$id_type" == "2" ]]; then
        echo "Please enter the Record ID:"
        read record_id
    else
        echo "Invalid selection. To retrieve the data, either an Envelope ID or Record ID is required. Please try again."
        exit 1
    fi
else
    echo "To retrieve the data, either an Envelope ID or Record ID is required. Please try again."
    exit 1
fi

# Final check for Record ID
if [ -z "$record_id" ]; then
    echo "Error: Record ID is missing. To retrieve the data, either an Envelope ID or Record ID is required. Please try again."
    exit 1
fi

# Store the value internally as RECIPIENT_ID_GUID to maintain compatibility with existing config structures if needed
echo $record_id > ../../config/RECIPIENT_ID_GUID

# --- Step 4: Call Trust Records Endpoint ---
#ds-snippet-start:TrustRecords1Step3
declare -a Headers=('--header' "Authorization: Bearer ${access_token}" '--header' "Accept: application/json")
#ds-snippet-end:TrustRecords1Step3

#ds-snippet-start:TrustRecords1Step4
uri="https://api-d.docusign.com/v1/accounts/${account_id}/trust-records/${record_id}"
response_json=$(mktemp /tmp/trust_record.XXXXXX)
#ds-snippet-end:TrustRecords1Step4
echo "-------------------------------------------------------"
echo "Fetching Trust Records for Record ID: $record_id"
echo "-------------------------------------------------------"

status=$(curl -s -w "%{http_code}" --request GET "${uri}" "${Headers[@]}" --output ${response_json})

if [[ "$status" -gt "201" ]]; then
    echo "Error fetching trust records. Status: $status"
    cat $response_json
    exit 1
fi

# Display the API response to the user
echo "API Response:"
cat $response_json
echo -e "\n-------------------------------------------------------"

# Parse the relative pdf_url
#ds-snippet-start:TrustRecords1Step5
pdf_path=$(cat $response_json | grep -o '"pdf_url":"[^"]*' | sed 's/"pdf_url":"//')

if [ -n "$pdf_path" ]; then
    # Construct the Full URL using the requested base
    clean_path=$(echo $pdf_path | sed 's/^\///')
    full_download_url="https://api-d.docusign.com/v1/${clean_path}"
#ds-snippet-end:TrustRecords1Step5
    echo "SUCCESS: The 'pdf_url' has been found in the API response."
    echo "Full PDF Download URL: $full_download_url"
    echo "-------------------------------------------------------"
    
    # Download Prompt
    read -p "Would you like to download the ID artifact (PDF) now? (y/n): " download_choice

    if [[ "$download_choice" =~ ^[Yy]$ ]]; then
        mkdir -p proofs
        file_name="identity_proof_$(date +%Y%m%d_%H%M%S).pdf"
        
        echo "Downloading PDF to proofs/$file_name..."
        
        curl -s -L --request GET "${full_download_url}" \
            --header "Authorization: Bearer ${access_token}" \
            --output "proofs/$file_name"

        if [ $? -eq 0 ] && [ -s "proofs/$file_name" ]; then
            echo "Download complete! PDF saved in the 'proofs' folder."
        else
            echo "Download failed or file is empty."
        fi
    fi
else
    echo "Note: API call was successful, but no 'pdf_url' was found in this record."
fi

# Cleanup
rm "$response_json"
[ -f "$response_file" ] && rm "$response_file"

echo "Done."