#!/bin/bash

REPO="$1"
MDFILE="$2"
PURPOSE="$3"
GITHUB_TOKEN="$4"

echo "📘 Improving $MDFILE from $REPO for purpose: $PURPOSE"

# ✅ Verify API Key
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ Error: OPENAI_API_KEY not set in environment variables!"
  exit 1
fi

# Clone the target repo (already handled by composite action)
cd "$GITHUB_WORKSPACE" || exit 1

# Install dependencies (using new OpenAI API)
python3 -m pip install --quiet openai

# Run Python script to improve markdown
python3 <<EOF
from openai import OpenAI
import os

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

with open("$MDFILE", "r", encoding="utf-8") as f:
    content = f.read()

response = client.chat.completions.create(
    model="gpt-4-turbo",
    messages=[{
        "role": "user", 
        "content": f"Improve this markdown to better {os.getenv('PURPOSE')}:\\n\\n'''{content}'''"
    }],
    temperature=0.7
)

with open("$MDFILE", "w", encoding="utf-8") as f:
    f.write(response.choices[0].message.content)
EOF

# Configure Git and push changes
git config --global user.name "github-actions[bot]"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add "$MDFILE"
git commit -m "Improved $MDFILE via OpenAI"

# Handle authentication for GitHub Actions
if [ -n "$GITHUB_TOKEN" ]; then
  git remote set-url origin "https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git"
fi

git push origin HEAD
