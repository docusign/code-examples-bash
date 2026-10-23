#apx-snippet-start:getWorkflowInstance
Status=$(curl -s -w "%{http_code}\n" -i \
    --request GET "https://api-d.docusign.com/v1/accounts/${account_id}/workflows/${workflow_id}/instances/${instance_id}" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:getWorkflowInstance