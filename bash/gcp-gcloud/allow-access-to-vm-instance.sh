#!/bin/bash

# This script will:
# - Add a tag to the VM instance
# - Create a custom role with the required permissions

# Pre-requisite:
# The file `allow-ssh-access-to-vm-instance.json` should be present in the same directory as this script.

# The email address of the user to be granted access
USER_EMAIL="franck.boullier@gmail.com"

# Set the Environment variables
PROJECT="data-store-dev"
INSTANCE_NAME="dsi-server-a0f8106b"
REGION="asia-southeast1"
ZONE="asia-southeast1-a"

ROLE_NAME="allow.ssh.access"
VM_TAG="allow-external-user-access"

# Set the project
gcloud config set project $PROJECT

# Add the user to the GCP project
# Check if the user exists in the project
if ! gcloud projects get-iam-policy $PROJECT --format="json" | jq -e '.bindings[].members[]' | grep -q "user:$USER_EMAIL"; then
    # Display a message if the user does not exist in the project
    echo "User $USER_EMAIL does not exist in the project. Adding the user."
    # Add the user to the project
    # We use the "viewer" role to grant the user initial access to the project
    gcloud projects add-iam-policy-binding $PROJECT \
        --member=user:$USER_EMAIL \
        --role=roles/viewer \
        --condition=None
else
    # Display a message if the user already exists in the project
    echo "User $USER_EMAIL already exists in the project."
fi

# Add the tag to the VM instance
# Check if the tag is already attached to the VM instance
if gcloud compute instances describe $INSTANCE_NAME --zone=$ZONE --project=$PROJECT --format="get(tags.items)" | grep -q "$VM_TAG"; then
    # Display a message if the tag is already attached to the VM instance
    echo "VM instance $INSTANCE_NAME already has the tag $VM_TAG."
else
    # Display a message if the tag is not attached to the VM instance
    echo "Adding tag $VM_TAG to VM instance $INSTANCE_NAME."
    # Add the tag to the VM instance
    gcloud compute instances add-tags $INSTANCE_NAME \
    --tags=$VM_TAG \
    --zone=$ZONE \
    --project=$PROJECT
fi

# Create a custom role with the required permissions
# Check if the custom role already exists
if gcloud iam roles describe $ROLE_NAME --project=$PROJECT > /dev/null 2>&1; then
    # Display a message if the custom role already exists
    echo "Custom role $ROLE_NAME already exists."
else
    # Display a message if the custom role does not exist
    echo "Creating custom role $ROLE_NAME."
    # Create the custom role with the required permissions
    gcloud iam roles create $ROLE_NAME \
      --project=${PROJECT} \
      --file=allow-ssh-access.json
fi

# Define the condition
CONDITION_EXPRESSION="resource.name.startsWith('projects/$PROJECT/zones/$ZONE/instances/$INSTANCE_NAME')"
CONDITION_TITLE="SpecificVMAccess"
CONDITION_DESCRIPTION="Access to a specific VM instance"

# Display a message before linting the condition
echo "Linting the condition to check for issues."
# Lint the condition
gcloud alpha iam policies lint-condition \
  --expression="$CONDITION_EXPRESSION" \
  --title="$CONDITION_TITLE" \
  --description="$CONDITION_DESCRIPTION" \
  --resource-name="projects/$PROJECT"

# Check if the condition linting was successful
if [ $? -ne 0 ]; then
  echo "Condition linting failed. Please check the condition syntax and try again."
  exit 1
fi

# Assign the custom role to the user
# Use the custom role created in the previous step
# Add a condition to limit to VM instances with a specific tag
gcloud projects add-iam-policy-binding $PROJECT \
 --member=user:$USER_EMAIL \
 --role=projects/$PROJECT/roles/$ROLE_NAME \
 --condition="expression=$CONDITION_EXPRESSION,title=$CONDITION_TITLE,description=$CONDITION_DESCRIPTION"

# All permissions have been granted - display a completion message
echo "Completed granting access to user $USER_EMAIL."