#!/usr/bin/env bash
# post-create-shared.sh — Common dev container setup logic
# Sourced by post-create.sh in both base and overlay templates.
# Idempotent: safe to re-run on container rebuild.
set -euo pipefail

# ── Pinned versions (update here when upgrading) ──────────────────────
NUGET_MCP_VERSION="1.2.3"
SQUAD_CLI_VERSION="0.9.1"
SPECKIT_TAG="v0.5.0"
MSDOCS_COMMIT="933e0c5044b938cbeb23709e1cb125c8d93395c0"
# ──────────────────────────────────────────────────────────────────────

BASHRC_MARKER="# TheSereyn devcontainer managed block"
COPILOT_DIR="/home/vscode/.copilot"

echo "--> Verifying tool versions"
dotnet --info
node --version
python3 --version
gh --version
az --version

# ── GitHub CLI Copilot extension ──────────────────────────────────────
echo "--> Installing GitHub CLI Copilot extension"
if gh auth status &>/dev/null; then
  gh extension install github/gh-copilot 2>/dev/null \
    || gh extension upgrade github/gh-copilot 2>/dev/null \
    || echo "  gh-copilot: already at latest"
else
  echo "  gh-copilot: skipped (run 'gh auth login' first, then 'gh extension install github/gh-copilot')"
fi

# ── Shell integration (idempotent via marker) ─────────────────────────
echo "--> Configuring shell integration"
if ! grep -qF "$BASHRC_MARKER" /home/vscode/.bashrc 2>/dev/null; then
  cat >> /home/vscode/.bashrc << 'BASHRC'
# TheSereyn devcontainer managed block
# Ensure ~/.local/bin is on PATH (uv tools, pip --user installs)
export PATH="$HOME/.local/bin:$PATH"

# GitHub Copilot CLI aliases — activated after gh auth login
if command -v gh &>/dev/null 2>&1; then
  eval "$(gh copilot alias -- bash 2>/dev/null)" 2>/dev/null || true
fi
# End TheSereyn managed block
BASHRC
  echo "  .bashrc: managed block added"
else
  echo "  .bashrc: managed block already present, skipping"
fi

# ── NuGet MCP server ─────────────────────────────────────────────────
echo "--> Installing NuGet MCP server (pinned v${NUGET_MCP_VERSION})"
if dotnet tool list -g 2>/dev/null | grep -q "nuget.mcp.server"; then
  echo "  nuget.mcp.server: already installed"
else
  dotnet tool install -g nuget.mcp.server --version "$NUGET_MCP_VERSION"
fi

# ── Squad CLI ─────────────────────────────────────────────────────────
echo "--> Installing Squad CLI (pinned v${SQUAD_CLI_VERSION})"
if npm list -g @bradygaster/squad-cli &>/dev/null; then
  echo "  squad-cli: already installed"
else
  npm install -g "@bradygaster/squad-cli@${SQUAD_CLI_VERSION}"
fi

# ── uv + Spec Kit CLI ────────────────────────────────────────────────
echo "--> Installing uv (Python package manager)"
python3 -m pip install --user --quiet uv
export PATH="$HOME/.local/bin:$PATH"

echo "--> Installing Spec Kit CLI (pinned to ${SPECKIT_TAG})"
if command -v specify &>/dev/null; then
  echo "  specify-cli: already installed"
else
  uv tool install specify-cli --from "git+https://github.com/github/spec-kit.git@${SPECKIT_TAG}"
fi

# ── Microsoft Docs MCP skills (pinned to commit SHA) ─────────────────
echo "--> Installing microsoftdocs/mcp skills (pinned ${MSDOCS_COMMIT:0:12})"
MSDOCS_RAW="https://raw.githubusercontent.com/microsoftdocs/mcp/${MSDOCS_COMMIT}"
SKILLS_DIR="$COPILOT_DIR/skills"
for skill in microsoft-docs microsoft-code-reference microsoft-skill-creator; do
  mkdir -p "$SKILLS_DIR/$skill"
  if ! curl -sfL "$MSDOCS_RAW/skills/$skill/SKILL.md" -o "$SKILLS_DIR/$skill/SKILL.md"; then
    echo "Error: failed to download $skill skill from microsoftdocs/mcp@${MSDOCS_COMMIT:0:12}" >&2
    exit 1
  fi
done
mkdir -p "$SKILLS_DIR/microsoft-skill-creator/references"
if ! curl -sfL "$MSDOCS_RAW/skills/microsoft-skill-creator/references/skill-templates.md" \
  -o "$SKILLS_DIR/microsoft-skill-creator/references/skill-templates.md"; then
  echo "Error: failed to download skill-templates.md from microsoftdocs/mcp@${MSDOCS_COMMIT:0:12}" >&2
  exit 1
fi

# ── User-level Copilot MCP config ────────────────────────────────────
echo "--> Seeding user-level Copilot MCP config"
COPILOT_MCP="$COPILOT_DIR/mcp.json"
if [ ! -f "$COPILOT_MCP" ]; then
  mkdir -p "$COPILOT_DIR"
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
