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

echo "--> Installing Squad CLI"
npm install -g @bradygaster/squad-cli

echo "--> Installing Playwright CLI"
npm install -g @playwright/cli@latest || true

echo "--> Installing Playwright browser binaries (this may take 5-10 minutes)"
npx playwright install --with-deps

echo "==> Dev container setup complete."
echo ""
echo "Next steps:"
echo "  - Run the first-time-setup prompt in Copilot Chat: @workspace /first-time-setup"
echo "  - Playwright browser binaries installed and ready"
echo "  - Azure MCP and Copilot plugin integrations can be configured via Copilot Chat once VS Code has loaded"
