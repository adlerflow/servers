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

---

**Last Updated:** 2025-11-16
**Repository:** https://github.com/modelcontextprotocol/servers
**MCP Version:** Protocol 1.x, SDK ~1.19.1 (TypeScript), ~1.0.0 (Python)
