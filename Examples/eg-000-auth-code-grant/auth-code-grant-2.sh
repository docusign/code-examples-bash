# Authorization Code Grant: exchange the code for the access token
#
# Argument 1: the Code from the first step
if [ $# -eq 0 ]
  then
    echo ""
    echo "Problem: you need to provide the code from the"
    echo "first step as the argument to this script."
    echo ""
fi

source ../startup_checks.sh
source ../../Env.txt

CODE="$1"
URL="${DS_AUTH_SERVER}/oauth/token"
AUTH="${DS_CLIENT_ID}:${DS_CLIENT_SECRET}"

echo ""
echo "Requesting the tokens from DocuSign..."
echo ""

tmpfile=$(mktemp /tmp/eg-000-script.XXXXXX)

# urlencode the arguments
curl --user "$AUTH" \
     --data-urlencode "grant_type=authorization_code" \
     --data-urlencode "code=${CODE}" \
     --request POST ${URL} > $tmpfile

# output is something like the following single line:
# {"access_token":"ey...","token_type":"Bearer","refresh_token":"ey...","expires_in":28800}

echo ""

# Pull out the access_token
DS_ACCESS_TOKEN=`sed 's/{\"access_token\":\"//' $tmpfile |
sed 's/\",\"token_type\":\"Bearer\"\,\"refresh_token\":\".*\",\"expires_in\":.*}//'` 

echo "$DS_ACCESS_TOKEN" > ../../DS_ACCESS_TOKEN
echo "Access token:"
echo $DS_ACCESS_TOKEN
echo ""
echo "The access token has been written to file DS_ACCESS_TOKEN for use by other scripts."

# Pull out the refresh_token
DS_REFRESH_TOKEN=`sed 's/{\"access_token\":\".*\",\"token_type\":\"Bearer\"\,\"refresh_token\":\"//' $tmpfile |
sed 's/\",\"expires_in\":.*}//'` 

echo ""
echo "Refresh token:"
echo $DS_REFRESH_TOKEN

rm "$tmpfile"
echo ""

echo "Running auth-code-grant-3.sh to obtain the default account..."
bash auth-code-grant-3.sh
