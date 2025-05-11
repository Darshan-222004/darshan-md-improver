#!/bin/bash

REPO="$1"
MDFILE="$2"
PURPOSE="$3"

echo "📘 Improving $MDFILE from $REPO for purpose: $PURPOSE"

# Clone the repo
git clone "$REPO" repo-clone
cd repo-clone || exit 1

# ✅ Check for API key
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ OPENAI_API_KEY not set"
  exit 1
fi

# ✅ Install OpenAI SDK safely
python3 -m pip install --quiet openai

# ✅ Run Python to read + improve markdown (pass shell vars safely)
python3 <<EOF
import openai
import os

# Set API key from env
openai.api_key = os.getenv("OPENAI_API_KEY")

# Read markdown content
with open("$MDFILE", "r", encoding="utf-8") as f:
    content = f.read()

# Get purpose from shell argument
purpose = "$PURPOSE"

# OpenAI request
response = openai.ChatCompletion.create(
    model="gpt-4-turbo",
    messages=[{
        "role": "user",
        "content": f"Improve the following markdown to better {purpose}:\n\n'''{content}'''"
    }],
    temperature=0.7
)

# Write improved content back
with open("$MDFILE", "w", encoding="utf-8") as f:
    f.write(response['choices']
