#apx-snippet-start:revokeWorkspaceUserAccess
Status=$(curl -s -w "%{http_code}\n" -i \
    --request POST "https://api-d.docusign.com/v1/accounts/${account_id}/workspaces/${workspace_id}/users/${user_id}/actions/revoke-access" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:revokeWorkspaceUserAccess
