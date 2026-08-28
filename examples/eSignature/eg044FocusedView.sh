#!/bin/bash
# Focused view
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

ds_access_token_path="config/ds_access_token.txt"
api_account_id_path="config/API_ACCOUNT_ID"
document_path="demo_documents/World_Wide_Corp_lorem.pdf"

# Obtain your OAuth token
# Note: Substitute these values with your own
ACCESS_TOKEN=$(cat "${ds_access_token_path}")

# Set up variables for full code example
# Note: Substitute these values with your own
ACCOUNT_ID=$(cat "${api_account_id_path}")

signer_country_code=""
signer_phone_number=""
use_phone_authentication=0
workflow_id=""
temp_files=()

cleanup_temp_files() {
    for temp_path in "$@"; do
        if [[ -n "$temp_path" && -f "$temp_path" ]]; then
            rm -f "$temp_path"
        fi
    done
}

write_api_failure_and_exit() {
    local step_name="$1"
    local http_status="$2"
    local response_file="$3"

    echo ""
    echo "${step_name} failed."

    if [[ -n "$http_status" ]]; then
        echo "HTTP status: ${http_status}"
    fi

    if [[ -n "$response_file" && -f "$response_file" ]]; then
        echo "DocuSign error: $(cat "$response_file")"
    fi

    cleanup_temp_files "${temp_files[@]}"
    exit 1
}

echo ""
read -r -p "Enter signer country code to enable optional phone authentication (press Enter to skip): " signer_country_code
read -r -p "Enter signer phone number to enable optional phone authentication (press Enter to skip): " signer_phone_number

signer_country_code=$(echo "$signer_country_code" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
signer_phone_number=$(echo "$signer_phone_number" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')

has_signer_country_code=0
has_signer_phone_number=0

if [[ -n "$signer_country_code" ]]; then
    has_signer_country_code=1
fi

if [[ -n "$signer_phone_number" ]]; then
    has_signer_phone_number=1
fi

if [[ "$has_signer_phone_number" -eq 1 && "$has_signer_country_code" -eq 0 ]]; then
    echo "Country code is required when phone number is provided."
    exit 1
fi

if [[ "$has_signer_country_code" -eq 1 && "$has_signer_phone_number" -eq 0 ]]; then
    echo "Phone number is required when country code is provided."
    exit 1
fi

if [[ "$has_signer_phone_number" -eq 1 ]]; then
    use_phone_authentication=1
    signer_country_code="${signer_country_code#+}"
    signer_phone_number=$(echo "$signer_phone_number" | tr -d '[:space:]()-')
    signer_phone_number="${signer_phone_number#+}"

    if [[ ! "$signer_country_code" =~ ^[0-9]{1,4}$ ]]; then
        echo "Country code must contain 1 to 4 digits."
        exit 1
    fi

    if [[ ! "$signer_phone_number" =~ ^[0-9]{4,20}$ ]]; then
        echo "Phone number must contain 4 to 20 digits."
        exit 1
    fi
fi

# Create the envelope.
# The signer recipient includes a clientUserId setting
#
#  document 1 (pdf) has tag /sn1/
#  The envelope will be sent to the signer.

base_path="https://demo.docusign.net/restapi"

# temp files:
request_data=$(mktemp /tmp/request-eg-044.XXXXXX)
response=$(mktemp /tmp/response-eg-044.XXXXXX)
doc1_base64=$(mktemp /tmp/eg-044-doc1.XXXXXX)
temp_files+=("$request_data" "$response" "$doc1_base64")

# Fetch doc and encode
base64 < "$document_path" | tr -d '\n' > "$doc1_base64"

if [[ "$use_phone_authentication" -eq 1 ]]; then
    identity_verification_response=$(mktemp /tmp/identity-verification-eg-044.XXXXXX)
    temp_files+=("$identity_verification_response")

    echo ""
    echo "Looking up Phone Authentication identity verification workflow..."

    identity_http_status=$(curl --silent --show-error \
        --header "Authorization: Bearer ${ACCESS_TOKEN}" \
        --header "Accept: application/json" \
        --request GET "${base_path}/v2.1/accounts/${ACCOUNT_ID}/identity_verification" \
        --output "${identity_verification_response}" \
        --write-out "%{http_code}")

    if [[ "$identity_http_status" -lt 200 || "$identity_http_status" -ge 300 ]]; then
        write_api_failure_and_exit "Identity verification lookup request" "$identity_http_status" "$identity_verification_response"
    fi

    workflow_id=$(php -r '
        $payload = json_decode(file_get_contents($argv[1]), true);
        if (!is_array($payload) || !isset($payload["identityVerification"]) || !is_array($payload["identityVerification"])) {
            exit(0);
        }
        foreach ($payload["identityVerification"] as $workflow) {
            if (isset($workflow["defaultName"]) && $workflow["defaultName"] === "Phone Authentication") {
                if (isset($workflow["workflowId"])) {
                    echo $workflow["workflowId"];
                }
                break;
            }
        }
    ' "$identity_verification_response")

    if [[ -z "$workflow_id" ]]; then
        echo "IDENTITY_WORKFLOW_INVALID_ID"
        cleanup_temp_files "${temp_files[@]}"
        exit 1
    fi
fi

echo ""
echo "Sending the envelope request to DocuSign..."
echo ""

identity_verification_json=""
if [[ "$use_phone_authentication" -eq 1 ]]; then
    identity_verification_json=$(cat <<EOF
,
                "identityVerification": {
                    "workflowId": "${workflow_id}",
                    "steps": null,
                    "inputOptions": [
                        {
                            "name": "phone_number_list",
                            "valueType": "PhoneNumberList",
                            "phoneNumberList": [
                                {
                                    "countryCode": "${signer_country_code}",
                                    "number": "${signer_phone_number}"
                                }
                            ]
                        }
                    ],
                    "idCheckConfigurationName": ""
                }
EOF
)
fi

doc1_base64_content=$(cat "$doc1_base64")

# Concatenate the different parts of the request
#ds-snippet-start:eSign44Step2
cat > "$request_data" <<EOF
{
    "emailSubject": "Please sign this document set",
    "documents": [
        {
            "documentBase64": "${doc1_base64_content}",
            "name": "Lorem Ipsum",
            "fileExtension": "pdf",
            "documentId": "1"
        }
    ],
    "recipients": {
        "signers": [
            {
                "email": "${SIGNER_EMAIL}",
                "name": "${SIGNER_NAME}",
                "recipientId": "1",
                "routingOrder": "1",
                "clientUserId": "1000"${identity_verification_json}
            }
        ]
    },
    "status": "sent"
}
EOF
#ds-snippet-end:eSign44Step2

# Call DocuSign to create the envelope
#ds-snippet-start:eSign44Step3
create_envelope_http_status=$(curl --silent --show-error \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --data-binary @"${request_data}" \
    --request POST "${base_path}/v2.1/accounts/${ACCOUNT_ID}/envelopes" \
    --output "${response}" \
    --write-out "%{http_code}")
#ds-snippet-end:eSign44Step3

if [[ "$create_envelope_http_status" -lt 200 || "$create_envelope_http_status" -ge 300 ]]; then
    write_api_failure_and_exit "Create envelope request" "$create_envelope_http_status" "$response"
fi

echo "Response: $(cat "$response")"
echo ""

envelope_id=$(php -r '
    $payload = json_decode(file_get_contents($argv[1]), true);
    if (isset($payload["envelopeId"])) {
        echo $payload["envelopeId"];
    }
' "$response")

if [[ -z "$envelope_id" ]]; then
    echo "Create envelope request failed: envelopeId was not returned."
    cleanup_temp_files "${temp_files[@]}"
    exit 1
fi

echo "EnvelopeId: ${envelope_id}"
echo ""

# Create a recipient view (an embedded signing view)
# that the signer will directly open in their browser to sign.
#
# The returnUrl is normally your own web app. DocuSign will redirect
# the signer to returnUrl when the DocuSign signing completes.
# For this example, we'll use http://httpbin.org/get to show the
# query parameters passed back from DocuSign

# temp files:
request_data=$(mktemp /tmp/request-eg-044.XXXXXX)
response=$(mktemp /tmp/response-eg-044.XXXXXX)
temp_files+=("$request_data" "$response")

#ds-snippet-start:eSign44Step4
cat > "$request_data" <<EOF
{
    "returnUrl": "http://httpbin.org/get",
    "authenticationMethod": "none",
    "email": "${SIGNER_EMAIL}",
    "userName": "${SIGNER_NAME}",
    "clientUserId": 1000,
    "frameAncestors": ["http://localhost:8080", "https://apps-d.docusign.com"],
    "messageOrigins": ["https://apps-d.docusign.com"]
}
EOF
#ds-snippet-end:eSign44Step4

echo ""
echo "Requesting the url for the embedded signing..."
echo ""

#ds-snippet-start:eSign44Step5
create_recipient_view_http_status=$(curl --silent --show-error \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header "Content-Type: application/json" \
    --data-binary @"${request_data}" \
    --request POST "${base_path}/v2.1/accounts/${ACCOUNT_ID}/envelopes/${envelope_id}/views/recipient" \
    --output "${response}" \
    --write-out "%{http_code}")
#ds-snippet-end:eSign44Step5

if [[ "$create_recipient_view_http_status" -lt 200 || "$create_recipient_view_http_status" -ge 300 ]]; then
    write_api_failure_and_exit "Create recipient view request" "$create_recipient_view_http_status" "$response"
fi

echo "Response: $(cat "$response")"

signing_url=$(php -r '
    $payload = json_decode(file_get_contents($argv[1]), true);
    if (isset($payload["url"])) {
        echo $payload["url"];
    }
' "$response")

if [[ -z "$signing_url" ]]; then
    echo "Create recipient view request failed: signing URL was not returned."
    cleanup_temp_files "${temp_files[@]}"
    exit 1
fi

host_url="http://localhost:8080"
if which xdg-open &> /dev/null; then
    xdg-open "$host_url"
elif which open &> /dev/null; then
    open "$host_url"
elif which start &> /dev/null; then
    start "$host_url"
fi

php ./examples/eSignature/lib/startServerForFocusedView.php "$INTEGRATION_KEY_AUTH_CODE" "$signing_url"

# cleanup
cleanup_temp_files "${temp_files[@]}"

echo ""
echo "Done."