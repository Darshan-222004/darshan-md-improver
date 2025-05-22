#!/bin/bash
set -euo pipefail

REPO="$1"
MDFILE="$2"
PURPOSE="$3"
GITHUB_TOKEN="${4:-}"

echo "=== Debug Information ==="
echo "📘 Repository: $REPO"
echo "📄 Target file: $MDFILE"
echo "🎯 Purpose: $PURPOSE"
echo "📁 Workspace: $GITHUB_WORKSPACE"
echo "Current directory: $(pwd)"
echo "Files in workspace:"
ls -la "$GITHUB_WORKSPACE"

# Verify file exists
MD_PATH="$GITHUB_WORKSPACE/$MDFILE"
[ -f "$MD_PATH" ] || { 
  echo "❌ Error: File $MD_PATH not found! Available files:";
  ls -la "$GITHUB_WORKSPACE";
  exit 1;
}

echo "✅ Found file at: $MD_PATH"

# Rest of your original script (Python processing, git commands etc.)
# ... [keep your existing implementation here] ...
