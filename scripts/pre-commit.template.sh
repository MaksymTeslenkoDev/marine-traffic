#!/bin/sh

# Abort on first failure
set -e

echo "🔍 Running ESLint + Prettier on staged files..."

# Collect staged JS/TS files (added/copied/modified)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts|jsx|tsx)$') || true

if [ -z "$STAGED_FILES" ]; then
  echo "✅ No JS/TS files staged. Skipping lint/format."
  exit 0
fi

echo "🧹 ESLint fixing..."
yarn eslint --fix $STAGED_FILES

echo "✨ Prettier formatting..."
yarn prettier --write $STAGED_FILES

echo "➕ Restaging updated files..."
echo "$STAGED_FILES" | xargs git add

echo "🔎 Final lint check..."
yarn eslint $STAGED_FILES

echo "✅ All staged files linted and formatted successfully!"
