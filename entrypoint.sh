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
[ -f "$MD_PATH" ] || { echo "❌ Error: File $MDFILE not found!"; exit 1; }

echo "✅ Found file. Current content:"
cat "$MD_PATH"

# Install Python dependencies
echo "🔧 Installing dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install openai tenacity

# Process the file
echo "🔄 Improving markdown..."
python3 <<EOF
import os
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def improve_content(content, purpose):
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{
            "role": "user",
            "content": f"Improve this markdown for {purpose}:\n\n'''{content}'''"
        }],
        temperature=0.7
    )
    return response.choices[0].message.content

with open("$MD_PATH", "r") as f:
    content = f.read()

improved = improve_content(content, "$PURPOSE")

with open("$MD_PATH", "w") as f:
    f.write(improved)
EOF

# Commit changes
echo "💾 Saving improvements..."
git config --global user.name "GitHub Action"
git config --global user.email "action@github.com"
git add "$MD_PATH"
git diff --cached --quiet || git commit -m "Improved $MDFILE for $PURPOSE [bot]"
[ -n "$GITHUB_TOKEN" ] && git push

echo "✅ Successfully improved $MDFILE"
