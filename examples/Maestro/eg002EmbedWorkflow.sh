# #!/bin/bash
# # https://developers.docusign.com/docs/maestro-api/maestro101/embed-workflow/
# # Embed a Maestro workflow after it has been triggered

# # Check that we're in a bash shell
# if [[ $SHELL != *"bash"* ]]; then
#     echo "PROBLEM: Run these scripts from within the bash shell."
# fi

# # Step 1: Obtain your OAuth token
# ACCESS_TOKEN=$(cat config/ds_access_token.txt)

# # Step 2: Read the account ID
# account_id=$(cat config/API_ACCOUNT_ID)

# # Step 3: Read the workflow ID created by the trigger workflow script
# workflow_id=$(cat config/WORKFLOW_ID)

# # Step 4: Verify a workflow has been created
# if [ -z "$workflow_id" ]; then
#     echo "❌ ERROR: No workflow found. Please trigger a workflow before running this embed script."
#     exit 0
# fi

# # Step 5: Construct your API headers
# declare -a Headers=('--header' "Authorization: Bearer ${ACCESS_TOKEN}" \
#     '--header' "Accept: application/json" \
#     '--header' "Content-Type: application/json")

# # Step 6: Prepare request body
# request_data=$(mktemp /tmp/request-embed.XXXXXX)
# printf \
# '{
#   "returnUrl": "https://example.com/return"
# }' > $request_data

# # Step 7: Make the POST request to generate the embed URL
# response=$(mktemp /tmp/response-embed.XXXXXX)
# Status=$(curl -s -w "%{http_code}\n" -i --request POST "https://api-d.docusign.net/maestro/v1/accounts/${account_id}/workflows/${workflow_id}/embed_url" \
#     "${Headers[@]}" \
#     --data-binary @$request_data \
#     --output ${response})

# # Step 8: Handle the response
# if [[ "$Status" -gt "201" ]]; then
#     echo ""
#     echo "❌ ERROR: Unable to generate embed URL for the workflow"
#     echo ""
#     cat $response
#     rm "$request_data"
#     rm "$response"
#     exit 0
# fi

# echo ""
# echo "✅ Embed URL successfully generated:"
# embed_url=$(grep '"url":' $response | sed -n 's/.*"url": "\([^"]*\)".*/\1/p')
# echo $embed_url

# # Optional: Output embed code for iframe usage
# echo ""
# echo "📎 Use this in your HTML:"
# echo "<iframe src=\"$embed_url\" width=\"100%\" height=\"600\" frameborder=\"0\" allowfullscreen></iframe>"

# # Clean up
# rm "$request_data"
# rm "$response"
