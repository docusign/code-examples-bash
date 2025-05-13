#!/bin/bash
# Embed a Maestro workflow instance using the URL returned from triggerWorkflow

# Ensure the script is run in a bash shell
if [[ $SHELL != *"bash"* ]]; then
    echo "PROBLEM: Run these scripts from within the bash shell."
    exit 1
fi

#check that create workflow script ran successfully
workflow_created=$(cat config/WORKFLOW_ID)
if [ -z "$workflow_created" ]; then
    echo "please create a worklow before running this example"
    exit 0
fi

# Step 2: Check that the instance URL exists
instance_url=$(cat config/INSTANCE_URL)
if [ -z "$instance_url" ]; then
    echo "No instance URL found. Please run the trigger workflow script first."
    exit 1
fi
# Step 3: Decode any escaped characters
decoded_instance_url=$(echo "$instance_url" | sed 's/\\u0026/\&/g')


host_url="http://localhost:8080"
if which xdg-open &> /dev/null  ; then
  xdg-open $host_url
elif which open &> /dev/null    ; then
  open $host_url
elif which start &> /dev/null   ; then
  start $host_url
fi
php ./examples/Maestro/lib/startServerForEmbeddedWorkflow.php "$decoded_instance_url"
# Step 4: Output for developer
echo ""
echo "✅ Workflow instance URL retrieved for workflow ID: $workflow_id"
echo ""
echo "🔗 URL:"
echo "$decoded_instance_url"
echo ""
echo "📎 Use this HTML snippet to embed the workflow in your application:"
echo ""
echo "<div class=\"formContainer\">"
echo "  <iframe src=\"$decoded_instance_url\" width=\"800\" height=\"600\"></iframe>"
echo "</div>"
