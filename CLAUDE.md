# CLAUDE.md - Model Context Protocol Servers Repository Guide

## Repository Overview

This repository contains **reference implementations** for the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/), maintained by Anthropic. It serves as:

- A collection of official reference servers showcasing MCP capabilities
- Examples demonstrating best practices for MCP server development
- Reference implementations using both TypeScript and Python MCP SDKs

**Key Information:**
- **License:** MIT
- **Organization:** npm workspaces monorepo
- **Primary Languages:** TypeScript (Node.js) and Python
- **Package Scope:** `@modelcontextprotocol/server-*` (TypeScript), `mcp-server-*` (Python)
- **Version:** 0.6.x series

## Repository Structure

```
/
├── src/                          # All server implementations
│   ├── everything/               # TypeScript - Reference/test server
│   ├── fetch/                    # Python - Web content fetching
│   ├── filesystem/               # TypeScript - File operations
│   ├── git/                      # Python - Git repository tools
│   ├── memory/                   # TypeScript - Knowledge graph memory
│   ├── sequentialthinking/       # TypeScript - Problem-solving sequences
│   └── time/                     # Python - Time/timezone conversions
├── scripts/                      # Build and release scripts
├── .github/workflows/            # CI/CD workflows
├── package.json                  # Root workspace configuration
├── tsconfig.json                 # Global TypeScript configuration
├── CONTRIBUTING.md               # Contribution guidelines
└── README.md                     # Main documentation (very large)
```

### Server Structure Patterns

**TypeScript Servers:**
```
src/{server-name}/
├── package.json                  # Package metadata, dependencies, scripts
├── tsconfig.json                 # May extend root config (optional)
├── vitest.config.ts             # Test configuration (using vitest)
├── index.ts                      # Main entry point (shebang: #!/usr/bin/env node)
├── lib.ts                        # Core implementation logic
├── *-utils.ts                    # Utility modules
├── __tests__/                    # Test files
│   └── *.test.ts
├── README.md                     # Server-specific documentation
└── Dockerfile                    # Docker build configuration
```

**Python Servers:**
```
src/{server-name}/
├── pyproject.toml               # Package metadata, dependencies
├── .python-version              # Python version specification
├── uv.lock                      # UV lock file for dependencies
├── src/
│   └── mcp_server_{name}/
│       ├── __init__.py
│       ├── __main__.py          # Entry point
│       └── server.py            # Main implementation
├── tests/ or test/              # Test directory
│   └── test_*.py
├── README.md                    # Server-specific documentation
└── Dockerfile                   # Docker build configuration
```

## Development Environment Setup

### TypeScript Servers

**Requirements:**
- Node.js 22.x
- npm (comes with Node.js)

**Setup:**
```bash
# Install dependencies for a specific server
cd src/{server-name}
npm ci

# Build the server
npm run build

# Watch mode for development
npm run watch

# Run tests (if available)
npm test
```

**Key Dependencies:**
- `@modelcontextprotocol/sdk` - Official MCP SDK (^1.19.1)
- `typescript` - TypeScript compiler (^5.6.2+)
- `vitest` - Test framework (^2.1.8+)
- `@vitest/coverage-v8` - Coverage reporting
- `shx` - Cross-platform shell commands

### Python Servers

**Requirements:**
- Python 3.10+
- UV (modern Python package manager)

**Setup:**
```bash
# Install UV if not already installed
# See: https://github.com/astral-sh/uv

# Install dependencies for a specific server
cd src/{server-name}
uv sync --frozen --all-extras --dev

# Run tests
uv run pytest

# Type checking
uv run pyright

# Build package
uv build
```

**Key Dependencies:**
- `mcp` - Official Python MCP SDK (^1.0.0)
- `pydantic` - Data validation (^2.0.0)
- `pytest` - Test framework
- `pyright` - Type checker
- `ruff` - Linter/formatter

## Key Development Conventions

### TypeScript Conventions

1. **Module System:** ES Modules (`"type": "module"`)
2. **TypeScript Config:**
   - Target: ES2022
   - Module: Node16
   - Strict mode enabled
   - Module resolution: Node16

3. **Entry Points:**
   - Must include shebang: `#!/usr/bin/env node`
   - Defined in `package.json` under `bin` field
   - Made executable via `shx chmod +x dist/*.js` in build script

4. **Import Extensions:**
   - Always use `.js` extension for imports (even for `.ts` files)
   - Example: `import { foo } from './lib.js';`

5. **Testing:**
   - Framework: **Vitest** (not Jest)
   - Test files: `__tests__/*.test.ts`
   - Coverage: `vitest run --coverage`
   - Config: `vitest.config.ts`

6. **Build Process:**
   ```json
   "scripts": {
     "build": "tsc && shx chmod +x dist/*.js",
     "prepare": "npm run build",
     "watch": "tsc --watch",
     "test": "vitest run --coverage"
   }
   ```

### Python Conventions

1. **Package Manager:** UV (not pip/poetry)
2. **Package Structure:**
   - Source in `src/mcp_server_{name}/`
   - Entry point: `__main__.py`
   - Main function exposed in `__init__.py`

3. **Type Annotations:**
   - All code should be type-annotated
   - Type checking with `pyright`

4. **Testing:**
   - Framework: pytest
   - Test directory: `tests/` or `test/`
   - Test files: `test_*.py`

5. **Dependencies:**
   - Managed in `pyproject.toml`
   - Locked with `uv.lock`
   - Dev dependencies under `[tool.uv]`

### Security Best Practices

1. **Path Validation:**
   - Always validate user-provided paths
   - Use allowlists for directory access (see filesystem server)
   - Resolve symlinks to prevent directory traversal
   - Normalize paths before validation

2. **Input Validation:**
   - Use Zod (TypeScript) or Pydantic (Python) for schema validation
   - Validate all tool inputs against defined schemas
   - Sanitize file paths and user inputs

3. **Error Handling:**
   - Provide clear, safe error messages
   - Don't leak sensitive information in errors
   - Use try-catch blocks appropriately

4. **Access Control:**
   - Implement proper authorization checks
   - Support MCP Roots protocol for dynamic access control
   - Document all security boundaries

### MCP Protocol Implementation Patterns

1. **Server Setup (TypeScript):**
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
  ToolSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  {
    name: "server-name",
    version: "0.6.2",
  },
  {
    capabilities: {
      tools: {},
      // resources: {},  // if providing resources
      // prompts: {},    // if providing prompts
      // roots: {},      // if supporting roots protocol
    },
  }
);
```

2. **Server Setup (Python):**
```python
from mcp.server import Server
from mcp.server.stdio import stdio_server

app = Server("server-name")

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await app.run(
            read_stream,
            write_stream,
            app.create_initialization_options()
        )
```

3. **Tool Definition:**
   - Use Zod (TypeScript) or Pydantic (Python) for input schemas
   - Convert schemas to JSON Schema for MCP
   - TypeScript: `zodToJsonSchema()`
   - Python: Use Pydantic's `.model_json_schema()`

4. **Tool Handler Pattern:**
   - Validate inputs first
   - Perform operations with proper error handling
   - Return structured responses
   - Include helpful error messages

### Documentation Requirements

Every server must include a comprehensive README.md with:

1. **Overview:**
   - Brief description of the server's purpose
   - Key features list

2. **Features Section:**
   - Bulleted list of capabilities
   - Links to relevant MCP protocol documentation

3. **API Documentation:**
   - Tools: Complete list with inputs, outputs, and behavior
   - Resources: If applicable
   - Prompts: If applicable

4. **Usage Examples:**
   - Claude Desktop configuration (JSON)
   - VS Code configuration (JSON)
   - Both Docker and NPX/UV installation methods
   - Installation badges for VS Code

5. **Build Instructions:**
   - Docker build command
   - Local development setup

6. **License:**
   - MIT License statement

## CI/CD Workflows

### GitHub Actions Workflows

**TypeScript Workflow (`.github/workflows/typescript.yml`):**
1. **Detect Packages:** Finds all TypeScript packages
2. **Test:** Runs tests for each package (if tests exist)
3. **Build:** Compiles TypeScript for each package
4. **Publish:** Publishes to npm on release

**Python Workflow (`.github/workflows/python.yml`):**
1. **Detect Packages:** Finds all Python packages
2. **Test:** Runs pytest for each package
3. **Build:** Runs pyright and builds distributions
4. **Publish:** Publishes to PyPI on release (trusted publishing)

**Key Points:**
- Workflows use matrix strategy for parallel execution
- Node.js version: 22
- Python version: Defined in `.python-version` per package
- Tests are optional but recommended
- All packages must build successfully

### Release Process

**Automated via `release.yml`:**
- Triggered on GitHub release publication
- Publishes all updated packages
- Uses npm tokens (TypeScript) and trusted publishing (Python)

**Manual Release:**
```bash
# Use the release script
python scripts/release.py
```

## Contributing Guidelines

### Acceptable Contributions

**Welcomed:**
- Bug fixes
- Usability improvements
- Features demonstrating MCP protocol capabilities (Resources, Prompts, Roots)
- Documentation improvements (for existing features)
- Links to third-party servers in README

**More Selective:**
- New features not core to server's purpose
- Highly opinionated features
- New vendor-neutral documentation

**Not Accepted:**
- New server implementations (publish independently and link in README)

### Testing Requirements

**TypeScript:**
- Use **Vitest** (not Jest)
- Add tests in `__tests__/` directory
- Aim for good coverage of core functionality
- Run tests before submitting: `npm test`

**Python:**
- Use **pytest**
- Add tests in `tests/` or `test/` directory
- Type-check with pyright: `uv run pyright`
- Run tests before submitting: `uv run pytest`

### Pull Request Process

1. **Follow PR Template:**
   - Description of changes
   - Server details (if modifying existing server)
   - Motivation and context
   - Testing performed
   - Breaking changes (if any)

2. **Checklist:**
   - Read MCP Protocol Documentation
   - Follow MCP security best practices
   - Update server's README if needed
   - Test with an MCP client
   - Follow repository style guidelines
   - Ensure tests pass locally
   - Add appropriate error handling
   - Document environment variables/config

3. **Commit Messages:**
   - Use conventional commit style when possible
   - Be descriptive and clear
   - Reference issues if applicable

## Common Patterns for AI Assistants

### When Adding Features

1. **Understand the Server's Purpose:**
   - Each server has a specific, focused purpose
   - Don't add features outside this scope
   - Consult CONTRIBUTING.md if uncertain

2. **Follow Existing Patterns:**
   - Look at existing tool implementations
   - Match naming conventions
   - Use same validation patterns
   - Follow error handling style

3. **Security First:**
   - Always validate inputs
   - Check for path traversal vulnerabilities
   - Sanitize user-provided data
   - Consider security implications

4. **Document Thoroughly:**
   - Update README.md with new tools
   - Include input/output specifications
   - Provide usage examples
   - Document any new configuration options

### When Fixing Bugs

1. **Add Tests:**
   - Write a test that reproduces the bug
   - Ensure fix resolves the test case
   - Don't break existing tests

2. **Consider Edge Cases:**
   - What if input is null/undefined?
   - What if paths are invalid?
   - What if files don't exist?

3. **Maintain Backwards Compatibility:**
   - Don't change existing tool signatures
   - Don't remove functionality without discussion
   - Flag breaking changes clearly

### When Writing Tests

**TypeScript (Vitest):**
```typescript
import { describe, it, expect } from 'vitest';

describe('Feature Name', () => {
  it('should do something specific', () => {
    // Arrange
    const input = 'test';

    // Act
    const result = myFunction(input);

    // Assert
    expect(result).toBe('expected');
  });
});
```

**Python (pytest):**
```python
def test_feature_name():
    """Test that feature does something specific."""
    # Arrange
    input_data = "test"

    # Act
    result = my_function(input_data)

    # Assert
    assert result == "expected"
```

### Code Quality Checklist

- [ ] TypeScript code compiles without errors
- [ ] Python code passes pyright type checking
- [ ] Tests pass locally
- [ ] README.md updated if adding/changing features
- [ ] Input validation added for new tools
- [ ] Error handling implemented
- [ ] Security implications considered
- [ ] Follows existing code style
- [ ] No hardcoded secrets or credentials
- [ ] Paths are validated and normalized

## Important Files Reference

- **CONTRIBUTING.md** - Contribution guidelines and policies
- **CODE_OF_CONDUCT.md** - Community code of conduct
- **SECURITY.md** - Security policy and reporting
- **README.md** - Main repository documentation (contains extensive third-party server list)
- **.github/pull_request_template.md** - PR template
- **scripts/release.py** - Release automation script

## MCP Protocol Resources

- **Official Documentation:** https://modelcontextprotocol.io/
- **TypeScript SDK:** https://github.com/modelcontextprotocol/typescript-sdk
- **Python SDK:** https://github.com/modelcontextprotocol/python-sdk
- **Protocol Specification:** https://modelcontextprotocol.io/docs
- **Client Concepts (Roots):** https://modelcontextprotocol.io/docs/learn/client-concepts#roots

## Common Commands Reference

### TypeScript

```bash
# Install dependencies for all workspaces
npm install

# Build all servers
npm run build --workspaces

# Build specific server
cd src/{server-name} && npm run build

# Watch mode
cd src/{server-name} && npm run watch

# Run tests
cd src/{server-name} && npm test

# Link for local testing
npm link --workspaces
```

### Python

```bash
# Setup a server
cd src/{server-name}
uv sync --frozen --all-extras --dev

# Run tests
uv run pytest

# Type check
uv run pyright

# Build package
uv build

# Run server locally
uv run mcp-server-{name}
```

## Version Management

- Versions follow semantic versioning
- Current version series: 0.6.x
- Versions are synchronized across all official servers
- Update `package.json` or `pyproject.toml` when bumping versions
- Release process is automated via GitHub Actions

## Notes for AI Assistants

1. **Read Before Modifying:**
   - Always check CONTRIBUTING.md before making changes
   - Review the specific server's README
   - Look at existing implementations for patterns

2. **Testing is Mandatory:**
   - Use Vitest for TypeScript (not Jest)
   - Use pytest for Python
   - Test with actual MCP clients when possible

3. **Security is Critical:**
   - These are reference implementations used by many
   - Path traversal vulnerabilities are serious
   - Input validation is non-negotiable

4. **Documentation is Part of the Code:**
   - Update README.md with all changes
   - Keep documentation accurate and comprehensive
   - Include examples for new features

5. **When in Doubt:**
   - Look at similar existing implementations
   - Consult MCP protocol documentation
   - Keep changes minimal and focused
   - Ask for clarification in PR discussions

## Claude Code Integration

This repository is commonly used within **Claude Code**, Anthropic's official CLI tool. Understanding Claude Code's configuration system helps AI assistants work more effectively.

### Repository Settings File

Projects may have a `.claude/settings.json` file that configures Claude Code behavior. Key settings that affect development:

**Permissions:**
```json
{
  "permissions": {
    "allow": ["Bash(npm run build:*)"],
    "ask": ["Bash(npm publish:*)", "Bash(git push:*)"],
    "deny": ["Bash(rm -rf:*)", "Read(.env)"],
    "defaultMode": "default"
  }
}
```

**Hooks** - Commands that run automatically during development:
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npm run lint:fix",
            "timeout": 10
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npm install"
          }
        ]
      }
    ]
  }
}
```

### Common Hooks for This Repository

**Recommended SessionStart Hook:**
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npm install",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

**Recommended PostToolUse Hooks:**
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npm run build --workspaces --if-present",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

### Understanding Hook Feedback

When hooks run, you may see feedback like:
```
<user-prompt-submit-hook>
Running pre-submission checks...
✓ All tests passed
</user-prompt-submit-hook>
```

**Important:** Treat hook feedback as if it came from the user. If a hook blocks an action or reports errors, adjust your approach accordingly.

### Sandbox Mode Considerations

Claude Code may run commands in a sandbox with restricted filesystem and network access. If sandbox violations occur:

1. **Check the command** - Some commands may be excluded from sandboxing (configured in `excludedCommands`)
2. **Verify paths** - Sandbox may restrict access to certain directories
3. **Network restrictions** - Sandbox may block certain network operations
4. **Adjust approach** - Use alternative methods if sandbox blocks necessary operations

### MCP Server Development in Claude Code

When developing MCP servers in this repository within Claude Code:

1. **Test Locally First:**
   ```bash
   cd src/{server-name}
   npm run build
   node dist/index.js --help
   ```

2. **Use MCP Inspector:**
   - Recommended for testing MCP servers
   - Provides interactive testing environment
   - See: https://github.com/modelcontextprotocol/inspector

3. **Integration Testing:**
   - Test with actual MCP clients (Claude Desktop, VS Code)
   - Verify all tools, resources, and prompts work correctly
   - Test error handling and edge cases

### Environment Variables

Projects may set environment variables via `.claude/settings.json`:

```json
{
  "env": {
    "NODE_ENV": "development",
    "LOG_LEVEL": "debug"
  }
}
```

These variables are available during development but should not be relied upon for server runtime behavior.

### Hook System Deep Dive

Claude Code's hook system allows you to run custom commands at specific points in the development lifecycle.

#### Hook Lifecycle Events

- **SessionStart** - Runs when a new session starts (ideal for installing dependencies)
- **SessionEnd** - Runs when a session ends
- **PreToolUse** - Runs before a tool is executed
- **PostToolUse** - Runs after a tool completes (ideal for linting/building)
- **Stop** - Runs when the agent finishes responding (ideal for git checks)
- **SubagentStop** - Runs when subagents finish responding
- **UserPromptSubmit** - Runs when a user submits a prompt
- **Notification** - Triggers on notifications
- **PreCompact** - Runs before context is compacted

#### Hook Input Format

Hooks receive JSON input via stdin:

```json
{
  "session_id": "abc123",
  "source": "startup|resume|clear|compact",
  "transcript_path": "/path/to/transcript.jsonl",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "cwd": "/workspace/repo",
  "stop_hook_active": false
}
```

#### Hook Output Format

Hooks can control their execution mode by outputting JSON to stdout:

```bash
#!/bin/bash
# Async mode - runs in background
echo '{"async": true, "asyncTimeout": 300000}'

# Your hook logic here
npm install
```

**Async vs Synchronous:**
- **Synchronous (default)**: Session waits for hook to complete. Safer, no race conditions.
- **Async**: Hook runs in background. Faster session startup, but may cause race conditions.

#### Hook Environment Variables

Available in all hooks:

- `$CLAUDE_PROJECT_DIR` - Repository root path
- `$CLAUDE_ENV_FILE` - Path to write session environment variables
- `$CLAUDE_CODE_REMOTE` - Set to "true" if running in Claude Code on the web

**Setting session variables:**
```bash
echo 'export PYTHONPATH="."' >> "$CLAUDE_ENV_FILE"
echo 'export NODE_ENV="development"' >> "$CLAUDE_ENV_FILE"
```

**Conditional execution (web only):**
```bash
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0  # Skip on local installations
fi
```

#### Hook Exit Codes

- `0` - Success, continue normally
- `1` - Error, display message but continue
- `2` - Warning/blocking error, display message and may affect workflow

#### Writing Effective Hooks

**Best practices:**

1. **Be idempotent** - Safe to run multiple times
2. **Be fast** - Avoid long-running operations in synchronous hooks
3. **Be non-interactive** - Never prompt for user input
4. **Handle errors gracefully** - Check if commands exist before running
5. **Use proper shebangs** - Start with `#!/bin/bash` or appropriate interpreter
6. **Set error handling** - Use `set -euo pipefail` for bash scripts
7. **Prevent recursion** - Check `stop_hook_active` in Stop hooks

**Example: SessionStart hook for this repository**

```bash
#!/bin/bash
set -euo pipefail

# Only run in Claude Code on the web
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

# Check if npm is available
if ! command -v npm &> /dev/null; then
  echo "npm not found, skipping dependency installation" >&2
  exit 0
fi

# Install dependencies (prefer 'install' over 'ci' for better caching)
npm install

# Install Python dependencies if needed
if [ -d "src/time" ] || [ -d "src/git" ] || [ -d "src/fetch" ]; then
  if command -v uv &> /dev/null; then
    for dir in src/*/; do
      if [ -f "${dir}pyproject.toml" ]; then
        echo "Installing Python dependencies for ${dir}"
        (cd "${dir}" && uv sync --frozen --all-extras --dev) || true
      fi
    done
  fi
fi

exit 0
```

**Example: Stop hook to check for uncommitted changes**

```bash
#!/bin/bash

# Read hook input
input=$(cat)

# Prevent recursion
stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active // false')
if [[ "$stop_hook_active" = "true" ]]; then
  exit 0
fi

# Only run in git repositories
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

# Check for uncommitted changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "⚠️  Uncommitted changes detected. Remember to commit and push!" >&2
  exit 2
fi

# Check for unpushed commits
current_branch=$(git branch --show-current)
if [[ -n "$current_branch" ]]; then
  if git rev-parse "origin/$current_branch" >/dev/null 2>&1; then
    unpushed=$(git rev-list "origin/$current_branch..HEAD" --count 2>/dev/null) || unpushed=0
    if [[ "$unpushed" -gt 0 ]]; then
      echo "⚠️  $unpushed unpushed commit(s). Remember to push to origin!" >&2
      exit 2
    fi
  fi
fi

exit 0
```

### Skills System

Claude Code supports a **Skills** system - specialized agents that can be invoked for specific tasks.

#### Available Skills

Skills are located in `~/.claude/skills/` or `.claude/skills/` (project-specific).

**session-start-hook skill**: Creates SessionStart hooks for dependency installation
- Analyzes project dependencies (npm, Python, cargo, etc.)
- Generates appropriate installation scripts
- Validates linter and test execution
- Commits and pushes the hook configuration

#### Using Skills

Skills are invoked with the `Skill` tool when the user's request matches the skill description.

**Skill structure:**
```markdown
---
name: skill-name
description: When to use this skill
---

# Skill Instructions

Detailed instructions for the AI assistant...
```

#### Creating Custom Skills

To create a project-specific skill:

```bash
mkdir -p .claude/skills/my-skill
cat > .claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: Description of when to use this skill
---

# My Custom Skill

Instructions for what this skill does...
EOF
```

### Best Practices for Claude Code Users

1. **Set up SessionStart hooks** to install dependencies automatically
   - Use async mode for faster startup (if race conditions are acceptable)
   - Prefer `npm install` over `npm ci` for better container caching
   - Check for `$CLAUDE_CODE_REMOTE` to only run in web environments

2. **Configure PostToolUse hooks** to run linters/formatters after edits
   - Use pattern matching to only run on specific tools (e.g., `Edit|Write`)
   - Set appropriate timeouts to prevent hanging
   - Make hooks idempotent and fast

3. **Use Stop hooks** for safety checks
   - Check for uncommitted changes
   - Verify tests pass before ending sessions
   - Remind to push changes to remote

4. **Use permissions** to prevent accidental destructive operations
   - `allow`: Safe operations that don't need confirmation
   - `ask`: Important operations that should be confirmed
   - `deny`: Dangerous operations that should never run

5. **Enable sandbox** for safer command execution
   - Restricts filesystem and network access
   - Configure `excludedCommands` for tools that don't work sandboxed
   - Use `autoAllowBashIfSandboxed` to reduce prompts

6. **Configure MCP servers** this repository provides via `.mcp.json`
   - Test servers locally before configuring
   - Use proper security boundaries
   - Document server configurations

### Example .claude/settings.json for This Repository

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "permissions": {
    "allow": [
      "Bash(npm run build:*)",
      "Bash(npm test:*)",
      "Bash(git status:*)",
      "Bash(git diff:*)"
    ],
    "ask": [
      "Bash(npm publish:*)",
      "Bash(git push:*)",
      "Bash(git commit:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Read(.env)",
      "Write(.env)"
    ]
  },
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "npm install",
            "timeout": 120
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "npm run build --workspace=src/$SERVER --if-present",
            "timeout": 30
          }
        ]
      }
    ]
  },
  "sandbox": {
    "enabled": true,
    "autoAllowBashIfSandboxed": true,
    "network": {
      "allowLocalBinding": true
    }
  }
}
```

---

**Last Updated:** 2025-11-16
**Repository:** https://github.com/modelcontextprotocol/servers
**MCP Version:** Protocol 1.x, SDK ~1.19.1 (TypeScript), ~1.0.0 (Python)
