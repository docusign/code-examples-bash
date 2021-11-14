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

function GetCCPhoneNum()
{
    echo ""
    read -p "Enter CC phone country code (U.S. is 1): " CC_PHONE_COUNTRY
    read -p "Enter CC phone number: " CC_PHONE_NUMBER
    CC_PHONE_NUMBER="${CC_PHONE_NUMBER//[!0-9]/}"
    echo ""
    echo "CC_PHONE_COUNTRY is " $CC_PHONE_COUNTRY
    echo "CC_PHONE_NUMBER is " $CC_PHONE_NUMBER
}

function GetSignerPhoneNum()
{
    echo ""
    read -p "Enter signer phone country code (U.S. is 1): " SIGNER_PHONE_COUNTRY
    read -p "Enter signer phone number: " SIGNER_PHONE_NUMBER
    SIGNER_PHONE_NUMBER="${SIGNER_PHONE_NUMBER//[!0-9]/}"
    echo ""
    echo "SIGNER_PHONE_COUNTRY is " $SIGNER_PHONE_COUNTRY
    echo "SIGNER_PHONE_NUMBER is " $SIGNER_PHONE_NUMBER
}

function GetSignerEmail()
{
  while [[ $EMAIL != *"@"* ]]; do
      echo ""
      read -p "Enter an email address for the signer: " EMAIL
      read -p "Enter a name for the signer: " NAME
      echo ""
      echo "EMAIL is " $EMAIL
      echo "NAME is " $NAME
done
}

export -f GetSignerEmail
export -f CheckForValidCCEmail
export -f CheckForValidNotCheckedEmail
export -f GetCCPhoneNum
export -f GetSignerPhoneNum