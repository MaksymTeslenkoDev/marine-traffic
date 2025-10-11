#!/bin/sh
echo "🔒 Checking for vulnerabilities..."
yarn audit --groups dependencies --level moderate
if [ $? -ne 0 ]; then
  echo "⚠️  Vulnerabilities found. Push aborted."
  exit 1
fi
echo "✅ No moderate or higher vulnerabilities detected."