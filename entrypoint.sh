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

MD_PATH="$GITHUB_WORKSPACE/$MDFILE"
[ -f "$MD_PATH" ] || { echo "❌ Error: File $MDFILE not found!"; exit 1; }

echo "✅ Found file. Current content:"
cat "$MD_PATH"

echo "🔧 Installing dependencies..."
python3 -m pip install --upgrade pip
python3 -m pip install openai tenacity

echo "🔄 Running markdown improver..."
python3 "$GITHUB_ACTION_PATH/improver.py" "$MD_PATH" "$PURPOSE"

echo "💾 Saving improvements..."
git config --global user.name "GitHub Action"
git config --global user.email "action@github.com"
git add "$MD_PATH"
git diff --cached --quiet || git commit -m "Improved $MDFILE for $PURPOSE [bot]"
[ -n "$GITHUB_TOKEN" ] && git push

echo "✅ Successfully improved $MDFILE"
