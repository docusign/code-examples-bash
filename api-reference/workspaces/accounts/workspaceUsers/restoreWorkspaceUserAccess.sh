#apx-snippet-start:restoreWorkspaceUserAccess
Status=$(curl -s -w "%{http_code}\n" -i \
    --request POST "https://api-d.docusign.com/v1/accounts/${account_id}/workspaces/${workspace_id}/users/${user_id}/actions/restore-access" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:restoreWorkspaceUserAccess
