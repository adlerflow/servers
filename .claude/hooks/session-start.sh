#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "🔧 Setting up MCP servers repository..."

# Check if npm is available
if ! command -v npm &> /dev/null; then
  echo "⚠️  npm not found, skipping dependency installation" >&2
  exit 0
fi

# Install root dependencies
echo "📦 Installing root dependencies..."
npm install

# Build the sequential thinking server
echo "🧠 Building sequential-thinking server..."
cd src/sequentialthinking
npm ci
npm run build
cd ../..

# Install Python dependencies if UV is available
if command -v uv &> /dev/null; then
  for dir in src/*/; do
    if [ -f "${dir}pyproject.toml" ]; then
      echo "🐍 Installing Python dependencies for ${dir}..."
      (cd "${dir}" && uv sync --frozen --all-extras --dev) || true
    fi
  done
fi

echo "✅ MCP servers repository ready!"
exit 0
