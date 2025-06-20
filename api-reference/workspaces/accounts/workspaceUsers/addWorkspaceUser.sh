#apx-snippet-start:addWorkspaceUser
printf \
'{
    "email": "'"${email}"'",
    "first_name": "'"${first_name}"'",
    "last_name": "'"${last_name}"'",
    "role_id": "'"${role_id}"'"
}' >> $request_data

Status=$(curl -s -w "%{http_code}\n" -i \
    --request POST "https://api-d.docusign.com/v1/accounts/${account_id}/workspaces/${workspace_id}/users" \
    --header "Authorization: Bearer ${access_token}" \
    --header 'Content-Type: application/json' \
    --data-binary @${request_data} \
    --output ${response})
#apx-snippet-end:addWorkspaceUser
