# Installing Sequential Thinking MCP Server in Other Repositories

This guide explains how to add the Sequential Thinking MCP server to any GitHub repository for use with Claude Code on the web.

## Quick Installation

### Option 1: Using the Installation Script

```bash
# In your repository root
curl -fsSL https://raw.githubusercontent.com/modelcontextprotocol/servers/main/install-sequential-thinking.sh | bash
```

Or download and run manually:

```bash
wget https://raw.githubusercontent.com/modelcontextprotocol/servers/main/install-sequential-thinking.sh
chmod +x install-sequential-thinking.sh
./install-sequential-thinking.sh
```

### Option 2: Manual Configuration

Create `.mcp.json` in your repository root:

```json
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
```

Create or update `.claude/settings.json`:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "enableAllProjectMcpServers": true
}
```

## What Gets Installed

1. **`.mcp.json`** - MCP server configuration
   - Uses `npx` to run the published npm package
   - No build step required
   - Automatically available in Claude Code sessions

2. **`.claude/settings.json`** - Claude Code configuration
   - Enables all project MCP servers automatically
   - Can be extended with additional permissions and hooks

## Usage in Claude Code

Once configured, the `sequential_thinking` tool becomes available in your Claude Code sessions:

### Features

- **Dynamic Problem Solving**: Break down complex problems step-by-step
- **Thought Revision**: Question and revise previous thoughts
- **Branch Exploration**: Explore alternative reasoning paths
- **Adaptive Planning**: Adjust thought count as understanding deepens
- **Hypothesis Testing**: Generate and verify solution hypotheses

### Example Usage

The AI assistant can invoke the tool like:

```json
{
  "name": "sequentialthinking",
  "arguments": {
    "thought": "Let me analyze this authentication bug step by step...",
    "nextThoughtNeeded": true,
    "thoughtNumber": 1,
    "totalThoughts": 5
  }
}
```

## Configuration Options

### Disable Thought Logging

To disable the visual thought output in the console:

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"],
      "env": {
        "DISABLE_THOUGHT_LOGGING": "true"
      }
    }
  }
}
```

### Additional Permissions

Add specific permissions for safer operation:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "permissions": {
    "allow": ["Bash(npm run build:*)", "Bash(npm test:*)"],
    "ask": ["Bash(git push:*)", "Bash(git commit:*)"],
    "deny": ["Bash(rm -rf:*)", "Read(.env)"]
  },
  "enableAllProjectMcpServers": true
}
```

## Troubleshooting

### Server Not Loading

1. Check `.mcp.json` exists in repository root
2. Verify `enableAllProjectMcpServers` is `true` in `.claude/settings.json`
3. Ensure files are committed to the repository
4. Restart your Claude Code session

### NPX Not Found

The sequential-thinking server requires Node.js and npm to be available in the Claude Code environment. This is typically available by default.

### Thought Logging Issues

If you don't see thought progression:
- Check `DISABLE_THOUGHT_LOGGING` is set to `"false"`
- Verify the MCP server is loading (check Claude Code logs)

## Advanced Configuration

### Multiple MCP Servers

You can add multiple MCP servers to `.mcp.json`:

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "${workspaceFolder}"]
    },
    "memory": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-memory"]
    }
  }
}
```

### Per-Project vs User-Level

- **Project level**: `.mcp.json` and `.claude/settings.json` in repo
  - Shared with all team members
  - Version controlled

- **User level**: `~/.claude/settings.json`
  - Personal preferences
  - Not shared with team

## Examples

### For a Python Project

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

No special Python configuration needed - works universally!

### For a TypeScript Project

Same configuration works for any language/framework.

### For a Monorepo

Place `.mcp.json` at the monorepo root for access across all packages.

## More Information

- [Sequential Thinking Server Documentation](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Claude Code Documentation](https://docs.claude.com/en/docs/claude-code)

## License

The Sequential Thinking MCP Server is licensed under the MIT License.
