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

function CheckForValidCCPhoneNum()
{
  if [[ $CC_PHONE_COUNTRY != (0|[1-9][0-9]?|998)$ || $CC_PHONE_COUNTRY == "" \
        $CC_PHONE_NUMBER != ^\(?([0-9]{3})\)?[-.●]?([0-9]{3})[-.●]?([0-9]{4})$ || $CC_PHONE_NUMBER == "" ]]; then
      echo ""
      read -p "Enter CC phone country code (U.S. is 1): " CC_PHONE_COUNTRY
      read -p "Enter CC phone number: " CC_PHONE_NUMBER
      CC_PHONE_NUMBER=`cat $CC_PHONE_NUMBER | sed 's/[^0-9]*//g'`
      while [[ $CC_PHONE_COUNTRY != (0|[1-9][0-9]?|998)$ || $CC_PHONE_COUNTRY == "" \
                $CC_PHONE_NUMBER != ^\(?([0-9]{3})\)?[-.●]?([0-9]{3})[-.●]?([0-9]{4})$ || $CC_PHONE_NUMBER == ""  ]] ; do
      echo ""
      read -p "Enter CC phone country code (U.S. is 1): " CC_PHONE_COUNTRY
      read -p "Enter CC phone number: " CC_PHONE_NUMBER
      done
      echo ""
      echo "CC_PHONE_COUNTRY is " $CC_PHONE_COUNTRY
      echo "CC_NAME is " $CC_NAME
fi
}

function CheckForValidRecipPhoneNum()
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
export -f CheckForValidCCPhoneNum
export -f CheckForValidRecipPhoneNum