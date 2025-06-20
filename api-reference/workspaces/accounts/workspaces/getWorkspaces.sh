#apx-snippet-start:getWorkspaces
Status=$(curl -s -w "%{http_code}\n" -i \
    --request GET "https://api-d.docusign.com/v1/accounts/${account_id}/workspaces" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:getWorkspaces
