#!/usr/bin/env bash
set -euo pipefail

# ── Blazor-specific pinned versions ──────────────────────────────────
PLAYWRIGHT_CLI_VERSION="0.1.6"
PLAYWRIGHT_MCP_VERSION="0.0.70"
# ─────────────────────────────────────────────────────────────────────

echo "==> Dev container setup starting (Blazor)..."

# Shared setup (common across all templates)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/post-create-shared.sh"

# ── Playwright (Blazor-specific) ─────────────────────────────────────
echo "--> Adding Playwright MCP to user-level Copilot config"
python3 - "$PLAYWRIGHT_MCP_VERSION" << 'PYEOF'
import json, sys
path = "/home/vscode/.copilot/mcp.json"
version = sys.argv[1]
try:
    with open(path) as f:
        config = json.load(f)
    config.setdefault("mcpServers", {})["playwright"] = {
        "command": "npx",
        "args": ["-y", f"@playwright/mcp@{version}"]
    }
    with open(path, "w") as f:
        json.dump(config, f, indent=2)
    print(f"Playwright MCP @{version} added to user-level config")
except Exception as e:
    print(f"Error: could not update mcp.json: {e}", file=sys.stderr)
    sys.exit(1)
PYEOF

echo "--> Installing Playwright CLI (pinned v${PLAYWRIGHT_CLI_VERSION})"
if npm list -g @playwright/cli &>/dev/null; then
  echo "  playwright-cli: already installed"
else
  npm install -g "@playwright/cli@${PLAYWRIGHT_CLI_VERSION}"
fi
playwright-cli install --skills

echo "--> Installing Playwright browser binaries (this may take 5-10 minutes)"
npx -y "@playwright/mcp@${PLAYWRIGHT_MCP_VERSION}" --help &>/dev/null || true
npx playwright install --with-deps

echo "==> Dev container setup complete."
echo ""
echo "Next steps:"
echo "  - Run the first-time-setup prompt in Copilot Chat: @workspace /first-time-setup"
echo "  - Playwright browser binaries installed and ready"
