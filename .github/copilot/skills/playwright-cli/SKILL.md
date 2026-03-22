---
name: "playwright-cli"
description: "Automates browser interactions for web testing, form filling, screenshots, and data extraction. Use when the user needs to navigate websites, interact with web pages, fill forms, take screenshots, test web applications, or extract information from web pages."
---

# Browser Automation with playwright-cli

## Quick Start

```bash
# Open new browser
playwright-cli open
# Navigate to a page
playwright-cli goto https://example.com
# Interact using refs from the snapshot
playwright-cli click e15
playwright-cli type "search query"
playwright-cli press Enter
# Take a screenshot
playwright-cli screenshot
# Close the browser
playwright-cli close
```

## Commands

### Core

```bash
playwright-cli open
playwright-cli open https://example.com/
playwright-cli goto https://example.com
playwright-cli type "search query"
playwright-cli click e3
playwright-cli dblclick e7
playwright-cli fill e5 "user@example.com"
playwright-cli drag e2 e8
playwright-cli hover e4
playwright-cli select e9 "option-value"
playwright-cli upload ./document.pdf
playwright-cli check e12
playwright-cli uncheck e12
playwright-cli snapshot
playwright-cli snapshot --filename=after-click.yaml
playwright-cli eval "document.title"
playwright-cli eval "el => el.textContent" e5
playwright-cli dialog-accept
playwright-cli dialog-dismiss
playwright-cli resize 1920 1080
playwright-cli close
```

### Navigation

```bash
playwright-cli go-back
playwright-cli go-forward
playwright-cli reload
```

### Keyboard

```bash
playwright-cli press Enter
playwright-cli press ArrowDown
playwright-cli keydown Shift
playwright-cli keyup Shift
```

### Mouse

```bash
playwright-cli mousemove 150 300
playwright-cli mousedown
playwright-cli mouseup
playwright-cli mousewheel 0 100
```

### Screenshots and PDF

```bash
playwright-cli screenshot
playwright-cli screenshot e5
playwright-cli screenshot --filename=page.png
playwright-cli pdf --filename=page.pdf
```

### Tabs

```bash
playwright-cli tab-list
playwright-cli tab-new
playwright-cli tab-new https://example.com/page
playwright-cli tab-close
playwright-cli tab-select 0
```

### Storage

```bash
playwright-cli state-save
playwright-cli state-load auth.json
playwright-cli cookie-list
playwright-cli cookie-get session_id
playwright-cli cookie-set session_id abc123
playwright-cli cookie-delete session_id
playwright-cli cookie-clear
playwright-cli localstorage-list
playwright-cli localstorage-get theme
playwright-cli localstorage-set theme dark
playwright-cli sessionstorage-list
```

### Network

```bash
playwright-cli route "**/*.jpg" --status=404
playwright-cli route "https://api.example.com/**" --body='{"mock": true}'
playwright-cli route-list
playwright-cli unroute "**/*.jpg"
```

### DevTools

```bash
playwright-cli console
playwright-cli network
playwright-cli tracing-start
playwright-cli tracing-stop
```

## Open Parameters

```bash
# Use specific browser
playwright-cli open --browser=chrome
playwright-cli open --browser=firefox
playwright-cli open --browser=webkit

# Use persistent profile
playwright-cli open --persistent
playwright-cli open --profile=/path/to/profile

# Close and clean up
playwright-cli close
playwright-cli delete-data
```

## Snapshots

After each command, playwright-cli provides a snapshot of the current browser state:

```
> playwright-cli goto https://example.com
### Page
- Page URL: https://example.com/
- Page Title: Example Domain
### Snapshot
[Snapshot](.playwright-cli/page-2026-02-14T19-22-42-679Z.yml)
```

Use `playwright-cli snapshot` for on-demand snapshots. Default to automatic file naming; use `--filename=` when the artifact is part of a workflow result.
