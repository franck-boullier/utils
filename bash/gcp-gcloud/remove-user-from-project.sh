#!/bin/bash

# This script will:
# - List all roles attached to the user
# - Remove the user from each role
# This will revoke the user's access to the project.

# Pre-requisite:
# jq should be installed to parse the JSON response from the gcloud command.

# Set required variables
PROJECT="data-store-dev"
USER_EMAIL="franck.boullier@gmail.com"

# Ensure jq is installed
if ! command -v jq &> /dev/null
then
    echo "jq could not be found, please install jq to use this script."
    exit 1
fi

# Set the project
gcloud config set project $PROJECT

# Get all roles attached to the user
bindings=$(gcloud projects get-iam-policy $PROJECT --format="json" | jq -c '.bindings[] | select(.members[] | contains("user:'$USER_EMAIL'"))')

# Remove the user from each role
if [ -z "$bindings" ]; then
    # Display a message if no roles are found for the user
    echo "No roles found for user $USER_EMAIL."
else
  echo "$bindings" | while IFS= read -r binding; do
    # Get the role from the binding
    role=$(echo "$binding" | jq -r '.role')

    # Check if there is a condition
    condition=$(echo "$binding" | jq -c '.condition // empty')

    if [ -z "$condition" ]; then
        # No condition, specify --condition=None
        # Display a message for each role removed from the user
        echo "Removing role $role from user $USER_EMAIL without condition."
        # Remove the user from the role
        gcloud projects remove-iam-policy-binding $PROJECT \
          --member=user:$USER_EMAIL \
          --role=$role \
          --condition=None
    else
        # Condition exists, use --all to remove all bindings
        # Display a message for each role removed from the user
        echo "Removing role $role from user $USER_EMAIL with condition."
        # Remove the user from the role
        gcloud projects remove-iam-policy-binding $PROJECT \
          --member=user:$USER_EMAIL \
          --role=$role \
          --all
    fi

    # Check if the role was successfully removed
    if [ $? -eq 0 ]; then
        # Display a message if the role was successfully removed
        echo "Successfully removed role $role from user $USER_EMAIL."
    else
        # Display a message if the role removal failed
        echo "Failed to remove role $role from user $USER_EMAIL."
    fi
  done
fi

# All roles have been removed - display a completion message
echo "Completed role removal for user $USER_EMAIL."