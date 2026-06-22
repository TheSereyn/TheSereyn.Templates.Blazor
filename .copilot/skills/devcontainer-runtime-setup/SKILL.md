---
name: "devcontainer-runtime-setup"
description: "Detect the host container runtime and configure a reliable Docker-in-Docker or Podman-in-Podman devcontainer experience when the user wants it."
---

# Devcontainer Runtime Setup

Use this skill when the user wants the devcontainer to support running Docker or Podman commands from inside the container.

## Goal

Make the setup as automatic as possible. Prefer a reliable default configuration, and ask the user only when the agent cannot safely determine the right settings.

## Decision flow

1. Ask whether the user wants container-in-container support enabled.
2. Ask which host runtime they are using:
   - Docker
   - Podman
3. Inspect the host runtime from the local machine:
   - `docker --version` or `podman --version`
   - `docker info` or `podman info`
   - Check whether the runtime is rootless and whether the expected socket or bridge is available
4. Choose the appropriate setup path:
   - Docker host → Docker-in-Docker configuration
   - Podman host → Podman-in-Podman configuration
5. Update the repo's `.devcontainer/devcontainer.json` with the smallest reliable configuration that enables the selected workflow.
6. If the host environment is ambiguous or blocked, ask the user for the minimum follow-up needed rather than failing silently.

## Preferred implementation pattern

- Use the working Podman-in-Podman pattern from the repository's temporary example as the reference for Podman hosts.
- Use the same style of configuration for Docker hosts, adapting it to Docker Desktop or a compatible Docker socket setup.
- Prefer the least invasive change that still enables container-in-container workflows.
- Keep the default devcontainer simple and avoid forcing this setup unless the user asked for it.

## What to do when setup is uncertain

If runtime detection is incomplete, do not stall the whole setup. Instead:

- make the safest conservative change that preserves normal devcontainer functionality
- explain what was configured and what remains to be verified
- ask the user for one small clarification if needed, such as whether they use rootless Podman or Docker Desktop

## Expected outcome

The user should end up with a devcontainer that is ready for container-in-container workflows when the host runtime supports it, without needing to manually reconstruct the full configuration from scratch.
