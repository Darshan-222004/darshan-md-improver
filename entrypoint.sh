#!/bin/bash

REPO="$1"
MDFILE="$2"
PURPOSE="$3"

echo "Improving $MDFILE from $REPO for purpose: $PURPOSE"

# Clone the repo
git clone "$REPO" repo-clone
cd repo-clone || exit 1

# Install OpenAI SDK (requires 'requests' also)
pip install openai --quiet

# Check for API key
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ OPENAI_API_KEY not set"
  exit 1
fi

# Read original markdown
CONTENT=$(<"$MDFILE")

# Create a temporary Python script to improve markdown
python3 <<EOF
import openai
import os

openai.api_key = os.getenv("OPENAI_API_KEY")

response = openai.ChatCompletion.create(
    model="gpt-4-turbo",
    messages=[{
        "role": "user",
        "content": f"Improve the following markdown to better $PURPOSE:\n\n'''{CONTENT}'''"
    }],
    temperature=0.7
)

with open("$MDFILE", "w") as f:
    f.write(response['choices'][0]['message']['content'])

print("✅ Markdown improvement done.")
EOF

