#!/bin/bash
set -euo pipefail

# Install Sequential Thinking MCP Server for Claude Code
# This script configures any GitHub repository to use the sequential-thinking MCP server
# when working with Claude Code on the web

echo "🧠 Installing Sequential Thinking MCP Server configuration..."

# Check if jq is available for JSON manipulation
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq is not installed. Installing basic configuration without merging..."
    MERGE=false
else
    MERGE=true
fi

# Create .mcp.json
echo "📝 Configuring MCP server..."

if [ -f ".mcp.json" ] && [ "$MERGE" = true ]; then
    # Merge with existing configuration
    echo "   Merging with existing .mcp.json..."
    jq '.mcpServers["sequential-thinking"] = {
        "command": "npx",
        "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
        "env": {"DISABLE_THOUGHT_LOGGING": "false"}
    }' .mcp.json > .mcp.json.tmp && mv .mcp.json.tmp .mcp.json
else
    # Create new configuration
    cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-sequential-thinking"
      ],
      "env": {
        "DISABLE_THOUGHT_LOGGING": "false"
      }
    }
  }
}
EOF
fi

# Create or update .claude/settings.json
echo "⚙️  Configuring Claude Code settings..."

mkdir -p .claude

if [ -f ".claude/settings.json" ] && [ "$MERGE" = true ]; then
    # Merge with existing configuration
    echo "   Merging with existing .claude/settings.json..."
    jq '.enableAllProjectMcpServers = true' .claude/settings.json > .claude/settings.json.tmp && mv .claude/settings.json.tmp .claude/settings.json
else
    # Create minimal configuration
    cat > .claude/settings.json << 'EOF'
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "enableAllProjectMcpServers": true
}
EOF
fi

echo ""
echo "✅ Sequential Thinking MCP Server configured successfully!"
echo ""
echo "📚 What's been configured:"
echo "   • .mcp.json - MCP server configuration using npx"
echo "   • .claude/settings.json - Claude Code settings to enable the server"
echo ""
echo "🎯 Next steps:"
echo "   1. Commit these files to your repository"
echo "   2. Open your repository in Claude Code on the web"
echo "   3. The sequential_thinking tool will be available automatically"
echo ""
echo "🧠 The sequential_thinking tool provides:"
echo "   • Dynamic problem-solving with step-by-step thinking"
echo "   • Thought revision and refinement"
echo "   • Branch exploration for alternative reasoning paths"
echo "   • Adaptive planning with adjustable thought counts"
echo ""
echo "For more information, see:"
echo "https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking"
