# First leg of Authorization Code Grant
source ../startup_checks.sh
source ../../Env.txt

SCOPE="signature"
URL_AUTH_START=$(cat <<END
${DS_AUTH_SERVER}/oauth/auth?\
response_type=code\
&scope=${SCOPE}\
&client_id=${DS_CLIENT_ID}\
&state=${DS_AUTH_STATE}\
&redirect_uri=${DS_REDIRECT_URL_ENCODED}
END
)

echo ""
echo "Open your browser to"
echo "$URL_AUTH_START"
echo ""
echo "Copy the resulting code parameter to the auth-code-grant-02.sh command:"
echo "bash auth-code-grant-2.sh 123456"


echo ""
echo "Attempting to automatically open your browser..."
if which open > /dev/null 2>/dev/null
then
  open "$URL_AUTH_START"
elif which start > /dev/null
then
  start "$URL_AUTH_START"
fi

