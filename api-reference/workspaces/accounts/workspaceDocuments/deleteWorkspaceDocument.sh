#apx-snippet-start:deleteWorkspaceDocument
Status=$(curl -s -w "%{http_code}\n" -i \
    --request DELETE "https://api-d.docusign.com/v1/accounts/${account_id}/workspaces/${workspace_id}/documents/${document_id}" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:deleteWorkspaceDocument
