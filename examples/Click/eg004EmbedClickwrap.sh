#!/bin/bash
# https://developers.docusign.com/docs/click-api/how-to/embed-clickwraps
<<<<<<< HEAD
# How to embed a clickwrap
=======
# How to embed a Clickwrap
>>>>>>> add-click-api
#
# Check that we're in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
fi

# Set up variables for full code example
# Note: Substitute these values with your own
account_id=$(cat config/API_ACCOUNT_ID)

# Get a Clickwrap ID
if [ -f "config/CLICKWRAP_ID" ]; then
    clickwrap_id=$(cat config/CLICKWRAP_ID)
else
    echo ""
    echo "Clickwrap ID is needed. Please run step 1 and 2 - Create and Activate Clickwrap..."
    exit 0
fi

echo ""
<<<<<<< HEAD
echo "To embed this clickwrap in your website or application, share this code with your developer:"
=======
echo "To embed this Clickwrap in your website or application, share this code with your developer:"
>>>>>>> add-click-api
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
