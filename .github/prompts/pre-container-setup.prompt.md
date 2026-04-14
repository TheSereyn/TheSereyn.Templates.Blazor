---
mode: text
description: "Host-level prerequisites. Complete these before opening the dev container. If you used 'Use this template' on GitHub, many of these are likely already done."
---

# Pre-Container Setup

Complete these steps on your local machine before opening the dev container.

If you used **"Use this template"** on GitHub to create your repo, you've already started — check off the steps below that still need doing.

## Steps

### 1. Create Your Repository

On GitHub, click **"Use this template" → "Create a new repository"**, then clone the new repo locally:

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>
```

> If you're reading this prompt from your cloned repo, you've already completed this step.

### 2. Container Runtime

Install **[Docker Desktop](https://www.docker.com/)** or **[Podman Desktop](https://podman.io/)** — either works as the container runtime. Make sure the runtime is running before proceeding.

> **Podman users:** Podman Desktop is the recommended path. If you use the Podman CLI directly on Linux, ensure you have Docker CLI compatibility enabled (`podman-docker` package or `podman.socket`).

### 3. VS Code + Dev Containers Extension

Install [VS Code](https://code.visualstudio.com/) and the **Dev Containers** extension (`ms-vscode-remote.remote-containers`).

If you prefer another container-aware editor (e.g., Cursor, JetBrains), verify it supports the Dev Containers spec.

### 4. Git Identity

Verify your git identity is configured (this carries into the container):

```bash
git config --global user.name
git config --global user.email
```

If either is blank, set them:

```bash
git config --global user.name "Your Name"
git config --global user.email "your@email.com"
```

### 5. Set Container Name

Open `.devcontainer/devcontainer.json` in any text editor on your host machine and replace `{{PROJECT_NAME}}` with your project name.

> **Why now?** The container runtime reads the container name at build time. If you change it inside the container after the first build, the name won't update until you do a full container rebuild.

### 6. Open in Dev Container

Open the repo folder in VS Code. When prompted, click **"Reopen in Container"**.

If the prompt doesn't appear, run the command palette (`Ctrl+Shift+P` / `Cmd+Shift+P`) and select **"Dev Containers: Reopen in Container"**.

### 7. Wait for Post-Create

The container will build and run `post-create.sh` automatically. Watch the terminal for output.

This installs tools and configures the development environment. It may take several minutes on first build.

### 8. Next Step

Once the container is ready, open **Copilot Chat** and run the environment check:

```
@workspace /environment-check
```

When the environment check passes, run the project setup:

```
@workspace /project-setup
```
