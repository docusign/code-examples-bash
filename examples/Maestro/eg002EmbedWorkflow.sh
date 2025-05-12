#!/bin/bash
# https://developers.docusign.com/docs/maestro-api/maestro101/embed-workflow/
# Generates an embeddable Maestro workflow URL using the workflow ID

# Ensure bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
    exit 1
fi

# Step 1: Load required config values
ACCESS_TOKEN=$(cat config/ds_access_token.txt)
account_id=$(cat config/API_ACCOUNT_ID)
workflow_id=$(cat config/WORKFLOW_ID)

# Step 2: Validate workflow ID exists
if [ -z "$workflow_id" ]; then
    echo "❌ ERROR: No workflow ID found. Please run the trigger workflow script first."
    exit 1
fi

# Step 3: Set Maestro API base path
base_path="https://api-d.docusign.net/maestro/v1"

# Step 4: Prepare API headers
declare -a Headers=(
  '--header' "Authorization: Bearer ${ACCESS_TOKEN}"
  '--header' "Content-Type: application/json"
  '--header' "Accept: application/json"
)

# Step 5: Prepare POST body with returnUrl
request_data=$(mktemp /tmp/request-embed.XXXXXX)
printf \
'{
  "returnUrl": "https://example.com/return"
}' > $request_data

# Step 6: Make API call to get embed URL
response=$(mktemp /tmp/response-embed.XXXXXX)
Status=$(curl -s -w "%{http_code}\n" -i --request POST \
  "${base_path}/accounts/${account_id}/workflows/${workflow_id}/embed_url" \
  "${Headers[@]}" \
  --data-binary @$request_data \
  --output ${response})

# Step 7: Handle errors
if [[ "$Status" -gt "201" ]]; then
  echo "❌ ERROR: Failed to generate embed URL"
  cat $response
  rm "$request_data" "$response"
  exit 1
fi

# Step 8: Extract and display embed URL
embed_url=$(grep '"url":' $response | sed -n 's/.*"url": "\([^"]*\)".*/\1/p')

echo ""
echo "✅ Embed URL successfully generated:"
echo "$embed_url"

echo ""
echo "📎 You can use this HTML iframe to embed the workflow:"
echo "<iframe src=\"$embed_url\" width=\"100%\" height=\"600\" frameborder=\"0\" allowfullscreen></iframe>"

# Cleanup
rm "$request_data" "$response"
