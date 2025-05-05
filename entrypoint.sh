#!/bin/bash

# Exit the script if any command fails
set -e

# Input parameters
REPO=$1
MD_FILE=$2
PURPOSE=$3

# Temporary directory to clone the repository
TEMP_DIR=$(mktemp -d)

echo "Cloning repository: $REPO"
git clone "$REPO" "$TEMP_DIR"

# Change to the cloned repository's directory
cd "$TEMP_DIR"

# Check if the markdown file exists
if [[ ! -f "$MD_FILE" ]]; then
  echo "Error: Markdown file $MD_FILE not found in the repository."
  exit 1
fi

echo "Improving markdown file: $MD_FILE"

# Implement your logic here to improve the markdown file based on the 'PURPOSE'
# For example, adding a header or modifying content:

echo "Purpose: $PURPOSE"
echo -e "\n### Improved by Markdown Improver\n" >> "$MD_FILE"

# Add a simple improvement, like appending a footer
echo -e "\n<!-- Improved for purpose: $PURPOSE -->" >> "$MD_FILE"

# Optional: You can modify the markdown file using any tool or script based on the 'PURPOSE'

# After modification, let's commit the changes (optional step)
git config user.name "github-actions"
git config user.email "github-actions@github.com"
git add "$MD_FILE"
git commit -m "Improved markdown file: $MD_FILE for purpose: $PURPOSE"
git push origin main

echo "Markdown file improved and changes pushed to the repository."
