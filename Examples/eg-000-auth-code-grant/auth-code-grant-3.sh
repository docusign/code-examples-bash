# OAuth::userInfo
#
# Needs an Access Token
ACCESS_TOKEN_FILE="../../DS_ACCESS_TOKEN"
if [ ! -f "$ACCESS_TOKEN_FILE" ]; then
    echo ""
    echo "Problem: you need to provide an Access Token in file $ACCESS_TOKEN_FILE"
    exit 1;
fi

source ../startup_checks.sh
source ../../Env.txt
DS_ACCESS_TOKEN=`cat $ACCESS_TOKEN_FILE`

URL="${DS_AUTH_SERVER}/oauth/userinfo"

echo ""
echo "Requesting the user information from DocuSign..."
echo ""

tmpfile=$(mktemp /tmp/abc-script.XXXXXX)

curl --header "Authorization: Bearer ${DS_ACCESS_TOKEN}" \
     --request GET ${URL} > $tmpfile

# output is something like the following single line:
# {"sub":"14499850-43f1-4184-944f-55e5fed18870","name":"Larry Kluger","given_name":"Larry","family_name":"Kluger","created":"2015-05-20T11:48:23.363","email":"larry.kluger@docusign.com","accounts":[{"account_id":"8118f2b8-e5d4-427c-90e6-d7b3e4f85f8a","is_default":false,"account_name":"Xylophone World","base_uri":"https://demo.docusign.net"},{"account_id":"669032c8-89a1-4314-9387-bce4eef4d0fa","is_default":false,"account_name":"Xylophone 2","base_uri":"https://demo.docusign.net"},{"account_id":"1deb51c5-e67d-4606-b859-5e001a6ed1dd","is_default":false,"account_name":"World Wide Corporation","base_uri":"https://demo.docusign.net"},{"account_id":"e0ae72ed-4203-4173-8ff2-1a36f3f71e9f","is_default":false,"account_name":"DocuSign","base_uri":"https://demo.docusign.net"},{"account_id":"7f09961a-a22e-4ea2-8395-d7648b81f20c","is_default":false,"account_name":"DocuSign SBS Sandbox","base_uri":"https://demo.docusign.net","organization":{"organization_id":"9dd9d6cd-7ad1-461a-a432-a4653c6d6700","links":[{"rel":"self","href":"https://account-d.docusign.com/organizations/9dd9d6cd-7ad1-461a-a432-a4653c6d6700"}]}},{"account_id":"5e906335-c644-421f-9938-c81f8cd10ebe","is_default":false,"account_name":"DocuSign HQ Demo Admins","base_uri":"https://demo.docusign.net"},{"account_id":"65ab2bab-ce19-460c-b16f-308027ab475a","is_default":false,"account_name":"July 2017","base_uri":"https://demo.docusign.net"},{"account_id":"b124a74b-faa8-46f7-a55e-9bbdc12d2c2e","is_default":true,"account_name":"World Wide Corp","base_uri":"https://demo.docusign.net"},{"account_id":"5cd0e14b-d1be-4ff0-a0ab-27f24e73425a","is_default":false,"account_name":"DocuSign","base_uri":"https://demo.docusign.net"}]}

echo ""
echo "Response from DocuSign:"
cat $tmpfile


# Pull out the default account
DS_DEFAULT_ACCOUNT=`sed -n 's/.*\"\(.*\)\"\,\"is_default\":true.*/\1/p' $tmpfile`
echo "$DS_DEFAULT_ACCOUNT" > ../../DS_DEFAULT_ACCOUNT

echo ""
echo ""
echo "~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ "
echo ""
echo "Default account: ${DS_DEFAULT_ACCOUNT}"
echo ""
echo "The default account has been written to file DS_DEFAULT_ACCOUNT for use by other scripts."

rm "$tmpfile"
echo ""

