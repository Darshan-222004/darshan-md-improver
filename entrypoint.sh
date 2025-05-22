#!/bin/bash
set -euo pipefail

REPO="$1"
MDFILE="$2"
PURPOSE="$3"
GITHUB_TOKEN="${4:-}"

echo "=== STARTING PROCESS ==="
echo "Repository: $REPO"
echo "Target file: $MDFILE"
echo "Improvement goal: $PURPOSE"

# Verify file exists
MD_PATH="$GITHUB_WORKSPACE/$MDFILE"
echo "Checking for file at: $MD_PATH"

if [ ! -f "$MD_PATH" ]; then
  echo "❌ Error: File $MDFILE not found in repository!"
  echo "Available files:"
  ls -la "$GITHUB_WORKSPACE"
  exit 1
fi

echo "✅ Found file. Current content:"
cat "$MD_PATH"

# Process the file (your existing Python script)
echo "🔄 Improving markdown..."
python3 <<EOF
import os
from openai import OpenAI

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

with open("$MD_PATH", "r") as f:
    content = f.read()

response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{
        "role": "user",
        "content": f"Improve this markdown for better $PURPOSE:\n\n'''{content}'''"
    }]
)

improved = response.choices[0].message.content

with open("$MD_PATH", "w") as f:
    f.write(improved)
EOF

# Commit changes
echo "💾 Saving improvements..."
git config --global user.name "GitHub Action"
git config --global user.email "action@github.com"
git add "$MD_PATH"
git commit -m "Improved $MDFILE for $PURPOSE [bot]"
git push origin HEAD

echo "✅ Successfully improved $MDFILE"
