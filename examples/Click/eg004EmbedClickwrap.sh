#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/embed-clickwraps
# How to embed a clickwrap
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Configuration
# 1. Search for and update '{USER_EMAIL}' and '{USER_FULLNAME}'.
#    They occur and re-occur multiple times below.
# 2. Obtain an OAuth access token from
#    https://developers.docusign.com/oauth-token-generator
access_token=$(cat config/ds_access_token.txt)

# 3. Obtain your accountId from demo.docusign.net -- the account id is shown in
#    the drop down on the upper right corner of the screen by your picture or
#    the default picture.
account_id=$(cat config/API_ACCOUNT_ID)

# Get a ClickWrap ID
if [ -f "config/CLICKWRAP_ID" ]; then
    clickwrap_id=$(cat config/CLICKWRAP_ID)
else
    echo ""
    echo "ClickWrap ID is neded. Please run step 1 and 2 - Create and Activate ClickWrap..."
    exit 0
fi

echo "Write the code you need to embed your clickwrap in JavaScript. It should include the following HTML tags:"
echo "
<div id=\"ds-clickwrap\"></div>
<script src=\"https://demo.docusign.net/clickapi/sdk/latest/docusign-click.js\"></script>
<script>docuSignClick.Clickwrap.render({
      environment: 'https://demo.docusign.net',
      accountId: '${account_id}',
      clickwrapId: '${clickwrap_id}',
      clientUserId: 'UNIQUE_USER_ID'
    }, '#ds-clickwrap');</script>
"