#!/usr/bin/env bash
set -euo pipefail

echo "==> Dev container setup starting (Blazor)..."

echo "--> Verifying tool versions"
dotnet --info
node --version
gh --version
az --version

echo "--> Installing GitHub CLI Copilot extension"
gh extension install github/gh-copilot || true

echo "--> Configuring GitHub Copilot CLI shell integration"
cat >> /home/vscode/.bashrc << 'BASHRC'
# GitHub Copilot CLI aliases — activated after gh auth login
if command -v gh &>/dev/null 2>&1; then
  eval "$(gh copilot alias -- bash 2>/dev/null)" 2>/dev/null || true
fi
BASHRC

echo "--> Installing NuGet MCP server (requires .NET 10.0.5+)"
dotnet tool install -g nuget-mcp || true

echo "--> Installing Squad CLI"
npm install -g @bradygaster/squad-cli

echo "--> Installing microsoftdocs/mcp plugin skills"
MSDOCS_RAW="https://raw.githubusercontent.com/microsoftdocs/mcp/main"
COPILOT_DIR="/home/vscode/.copilot"
SKILLS_DIR="$COPILOT_DIR/skills"
for skill in microsoft-docs microsoft-code-reference microsoft-skill-creator; do
  mkdir -p "$SKILLS_DIR/$skill"
  curl -sL "$MSDOCS_RAW/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md" || true
done
mkdir -p "$SKILLS_DIR/microsoft-skill-creator/references"
curl -sL "$MSDOCS_RAW/skills/microsoft-skill-creator/references/skill-templates.md" \
  -o "$SKILLS_DIR/microsoft-skill-creator/references/skill-templates.md" || true

echo "--> Seeding user-level Copilot MCP config"
COPILOT_MCP="$COPILOT_DIR/mcp.json"
if [ ! -f "$COPILOT_DIR/mcp.json" ]; then
  cat > "$COPILOT_MCP" << 'MCP_EOF'
{
  "mcpServers": {
    "microsoft-learn": {
      "type": "http",
      "url": "https://learn.microsoft.com/api/mcp"
    }
  }
}
MCP_EOF
fi

echo "--> Adding Playwright MCP to user-level Copilot config"
python3 - << 'PYEOF'
import json, sys
path = "/home/vscode/.copilot/mcp.json"
try:
    with open(path) as f:
        config = json.load(f)
    config.setdefault("mcpServers", {})["playwright"] = {
        "command": "npx",
        "args": ["-y", "@playwright/mcp"]
    }
    with open(path, "w") as f:
        json.dump(config, f, indent=2)
    print("Playwright MCP added to user-level config")
except Exception as e:
    print(f"Warning: could not update mcp.json: {e}", file=sys.stderr)
PYEOF

echo "--> Installing Playwright CLI and skills"
npm install -g @playwright/cli@latest || true
playwright-cli install --skills || true

echo "--> Installing Playwright browser binaries (this may take 5-10 minutes)"
npx playwright install --with-deps

echo "==> Dev container setup complete."
echo ""
echo "Next steps:"
echo "  - Run the first-time-setup prompt in Copilot Chat: @workspace /first-time-setup"
echo "  - Playwright browser binaries installed and ready"
