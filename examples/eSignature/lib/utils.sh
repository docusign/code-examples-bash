function CheckForValidCCEmail()
{
  while [[ $CC_EMAIL != *"@"* ]]; do
      echo ""
      echo "Current cc email address is " $CC_EMAIL
      read -p "Enter an email address for the cc recipient different from the signer: " CC_EMAIL
      if [[ $CC_NAME == *"{"* || CC_NAME == "" ]] ; then
          echo ""
          echo "Current cc name is " $CC_NAME
          read -p "Enter a name for the CC Recipient: " CC_NAME
      fi
      echo ""
      echo "CC_EMAIL is " $CC_EMAIL
      echo "CC_NAME is " $CC_NAME
done
}

function CheckForValidNotCheckedEmail()
{
while [[ $SIGNER_NOT_CHECKED_EMAIL != *"@"* ]]; do
    echo ""
    echo "Current signer not checked email is " $SIGNER_NOT_CHECKED_EMAIL
    read -p "Enter an email address to route to when the checkbox is not checked: " SIGNER_NOT_CHECKED_EMAIL
    if [[ $SIGNER_NOT_CHECKED_NAME == *"{"* || SIGNER_NOT_CHECKED_NAME == "" ]] ; then
        echo ""
        echo "Current signer not checked name is " $SIGNER_NOT_CHECKED_NAME
        read -p "Enter a name for the recipient when the checkbox is not checked: " SIGNER_NOT_CHECKED_NAME
    fi
    echo ""
    echo "SIGNER_NOT_CHECKED_EMAIL is " $SIGNER_NOT_CHECKED_EMAIL
    echo "SIGNER_NOT_CHECKED_NAME is " $SIGNER_NOT_CHECKED_NAME
done
}

export -f CheckForValidCCEmail
export -f CheckForValidNotCheckedEmail