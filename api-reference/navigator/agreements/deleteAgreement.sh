#apx-snippet-start:deleteAgreement
Status=$(curl -s -w "%{http_code}\n" -i \
    --request DELETE "https://api-d.docusign.com/v1/accounts/{accountId}/agreements/{agreementId}" \
    --header "Authorization: Bearer ${access_token}" \
    --output ${response})
#apx-snippet-end:deleteAgreement