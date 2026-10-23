#apx-snippet-start:getWorkspaceUsers
Status=$(curl -s -w "%{http_code}\n" -i \
    --request GET "https://api-d.docusign.com/v1/accounts/${account_id}/workspaces/${workspace_id}/users" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:getWorkspaceUsers
