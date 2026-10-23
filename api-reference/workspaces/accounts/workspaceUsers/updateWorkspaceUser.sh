#apx-snippet-start:updateWorkspaceUser
printf \
'{
    "role_id": "'"${role_id}"'"
}' >> $request_data

Status=$(curl -s -w "%{http_code}\n" -i \
    --request PUT "https://api-d.docusign.com/v1/accounts/${account_id}/workspaces/${workspace_id}/users/${user_id}" \
    --header "Authorization: Bearer ${access_token}" \
    --header 'Content-Type: application/json' \
    --data-binary @${request_data} \
    --output ${response})
#apx-snippet-end:updateWorkspaceUser
