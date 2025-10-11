#!/bin/sh
# -----------------------------------------------------
# Setup local Git hooks from templates
# -----------------------------------------------------

set -e

echo "🔧 Setting up Git hooks..."

# Ensure we're inside a Git repo
if [ ! -d ".git" ]; then
  echo "❌ This directory is not a Git repository."
  exit 1
fi

# Define source templates and destination paths
HOOKS_DIR=".git/hooks"

# Create hooks dir if missing (very rare)
mkdir -p "$HOOKS_DIR"

# Copy templates
cp scripts/pre-commit.template.sh "$HOOKS_DIR/pre-commit"
cp scripts/pre-push.template.sh "$HOOKS_DIR/pre-push"

# Make them executable
chmod +x "$HOOKS_DIR/pre-commit" "$HOOKS_DIR/pre-push"

echo "✅ Git hooks installed successfully!"
echo "  - pre-commit → runs ESLint + Prettier on staged files"
echo "  - pre-push   → runs vulnerability audit"
