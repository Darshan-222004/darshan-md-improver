#!/bin/bash
set -euo pipefail

REPO="$1"
MDFILE="$2"
PURPOSE="$3"
GITHUB_TOKEN="${4:-}"

echo "📘 Improving $MDFILE from $REPO for purpose: $PURPOSE"

# Check for valid API key pattern
if [[ -z "$OPENAI_API_KEY" || "$OPENAI_API_KEY" == "sk-..."* ]]; then
    echo "⚠️ Warning: Invalid or placeholder OpenAI API key - skipping improvement"
    exit 0
fi

# Verify markdown file exists
[ -f "$MDFILE" ] || { echo "❌ Error: File $MDFILE not found!"; exit 1; }

cd "$GITHUB_WORKSPACE" || exit 1

echo "🔧 Installing dependencies..."
python3 -m pip install --quiet openai tenacity

echo "🛠 Processing markdown file..."
python3 <<EOF
import os
from openai import OpenAI
from tenacity import retry, stop_after_attempt, wait_exponential

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def improve_content(content, purpose):
    try:
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",  # Fallback to cheaper model
            messages=[{
                "role": "user",
                "content": f"Improve this markdown to better {purpose}:\n\n'''{content}'''"
            }],
            temperature=0.7,
            max_tokens=2000
        )
        return response.choices[0].message.content
    except Exception as e:
        print(f"⚠️ Warning: {str(e)}")
        return content  # Return original if error occurs

with open("$MDFILE", "r", encoding="utf-8") as f:
    content = f.read()

improved = improve_content(content, "$PURPOSE")

with open("$MDFILE", "w", encoding="utf-8") as f:
    f.write(improved)
EOF

# Only commit if there are changes
if git diff --quiet -- "$MDFILE"; then
    echo "🔄 No changes made to $MDFILE"
    exit 0
fi

git config --global user.name "github-actions[bot]"
git config --global user.email "41898282+github-actions[bot]@users.noreply.github.com"
git add "$MDFILE"
git commit -m "Docs: Improved $MDFILE for $PURPOSE [skip ci]"

[ -n "$GITHUB_TOKEN" ] && git push origin HEAD
echo "✅ Markdown update completed"
