#apx-snippet-start:createAgreementSummary
Status=$(curl -s -w "%{http_code}\n" -i \
    --request POST "https://api-d.docusign.com/v1/accounts/{accountId}/agreements/{agreementId}/ai/actions/summarize" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:createAgreementSummary