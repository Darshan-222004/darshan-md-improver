#!/bin/bash
set -euo pipefail  # Enable strict mode

REPO="$1"
MDFILE="$2"
PURPOSE="$3"
GITHUB_TOKEN="${4:-}"

echo "📘 Improving $MDFILE from $REPO for purpose: $PURPOSE"

# ✅ Verify API Key
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ Error: OPENAI_API_KEY not set in environment variables!"
  exit 1
fi

# Verify markdown file exists
if [ ! -f "$MDFILE" ]; then
  echo "❌ Error: File $MDFILE not found!"
  exit 1
fi

# Clone the target repo (already handled by composite action)
cd "$GITHUB_WORKSPACE" || exit 1

# Install dependencies
echo "🔧 Installing dependencies..."
python3 -m pip install --quiet openai

# Run Python script to improve markdown
echo "🛠 Processing markdown file..."
python3 <<EOF
import os
from openai import OpenAI
from openai import APIConnectionError, APIError, RateLimitError

try:
    client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

    with open("$MDFILE", "r", encoding="utf-8") as f:
        content = f.read()

    if not content.strip():
        raise ValueError("File is empty")

    response = client.chat.completions.create(
        model="gpt-4-turbo",
        messages=[{
            "role": "user", 
            "content": f"Improve this markdown to better {os.getenv('PURPOSE', '$PURPOSE')}. Maintain all technical accuracy while improving clarity, structure, and readability:\\n\\n'''{content}'''"
        }],
        temperature=0.7
    )

    improved_content = response.choices[0].message.content
    if not improved_content.strip():
        raise ValueError("Received empty response from API")

    with open("$MDFILE", "w", encoding="utf-8") as f:
        f.write(improved_content)

except (APIConnectionError, APIError, RateLimitError) as e:
    print(f"❌ OpenAI API error: {e}")
    exit(1)
except Exception as e:
    print(f"❌ Unexpected error: {e}")
    exit(1)
EOF

# Configure Git
echo "🔧 Configuring Git..."
git config --global user.name "github-actions[bot]"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"

# Check if there are changes to commit
if git diff --quiet -- "$MDFILE"; then
    echo "🔄 No changes detected in $MDFILE"
    exit 0
fi

# Commit and push changes
echo "💾 Committing and pushing changes..."
git add "$MDFILE"
git commit -m "Improved $MDFILE for better $PURPOSE [skip ci]"

if [ -n "$GITHUB_TOKEN" ]; then
    echo "🔑 Authenticating with GitHub token"
    git remote set-url origin "https://x-access-token:$GITHUB_TOKEN@github.com/${GITHUB_REPOSITORY}.git"
fi

git push origin HEAD
echo "✅ Successfully updated $MDFILE"
