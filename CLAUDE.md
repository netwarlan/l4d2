# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Dockerized Left 4 Dead 2 dedicated server. Part of the NETWAR game server infrastructure (`github.com/netwarlan`). Published to `ghcr.io/netwarlan/l4d2`.

## Build and Run

```bash
./build.sh              # builds: docker build -t ghcr.io/netwarlan/l4d2 .
./build.sh --no-cache   # extra args passed through to docker build

# Run locally
docker run -d -p 27015:27015/udp -p 27015:27015/tcp \
  -e L4D2_SERVER_HOSTNAME="DOCKER L4D2" \
  ghcr.io/netwarlan/l4d2
```

First startup downloads the full game (~15GB). Mount a volume at `/app/l4d2` to persist game files across restarts.

## Architecture

Two files do all the work:

- **Dockerfile**: Debian 13 slim base, installs i386 libraries (32-bit Source engine), sets up SteamCMD, creates non-root `steam` user. Includes a HEALTHCHECK on `srcds_linux` process.
- **run.sh**: Entrypoint script. Sequence: set env var defaults (`${VAR:-default}` style) → validate numeric inputs → optionally update game via SteamCMD → generate `server.cfg` from env vars using heredoc → optionally download remote config override → launch `srcds_run`.

CI uses a 3-job GitHub Actions workflow with semantic versioning via `netwarlan/action-semantic-versioning@v1`. Pushes to `main` and `workflow_dispatch` trigger builds (no PR trigger). The version job parses Conventional Commit messages (`fix:` → patch, `feat:` → minor, `BREAKING CHANGE:` → major) to determine version bumps. The build job delegates to the shared reusable workflow (`netwarlan/action-container-build`). Docker images are tagged with branch name, `latest` (on main), SHA, and semantic version (when bumped). A GitHub release with changelog is created automatically when a new version is detected.

### Internal directory layout

```
/app/
├── steamcmd/          # SteamCMD installation
├── l4d2/              # GAME_DIR — game files installed here
│   ├── srcds_run      # Server launcher script (provided by Valve)
│   ├── steam_appid.txt
│   └── left4dead2/
│       └── cfg/       # Server config files (server.cfg written here by run.sh)
└── run.sh             # Entrypoint
```

### SteamCMD two-pass update workaround

The update logic in `run.sh` uses a two-pass approach to work around [ValveSoftware/steam-for-linux#11522](https://github.com/ValveSoftware/steam-for-linux/issues/11522): first downloads with `@sSteamCmdForcePlatformType windows`, then re-runs with `linux` platform and `validate`. Both passes are required — do not simplify to a single pass.

## SteamCMD Authentication

L4D2 (app ID 222860) was removed from anonymous dedicated server downloads in November 2024. Requires authenticated Steam credentials via env vars: `STEAMCMD_USER`, `STEAMCMD_PASSWORD`, `STEAMCMD_AUTH_CODE`. MFA may require manual approval.

## Environment Variables

All prefixed with `L4D2_`. Key variables and their defaults:

| Variable | Default | Notes |
|---|---|---|
| `L4D2_SERVER_PORT` | 27015 | Validated as numeric |
| `L4D2_SERVER_MAXPLAYERS` | 4 | Validated as numeric |
| `L4D2_SERVER_MAP` | c1m1_hotel | Starting map |
| `L4D2_SERVER_HOSTNAME` | L4D2 Server | Supports spaces |
| `L4D2_SVLAN` | 0 | Set to 0 for internet play |
| `L4D2_SERVER_UPDATE_ON_START` | true | Runs SteamCMD app_update on startup |
| `L4D2_SERVER_VALIDATE_ON_START` | false | Runs SteamCMD app_update with `validate` flag on startup |
| `L4D2_SERVER_UPDATE_ONLY_THEN_STOP` | false | Downloads game files via SteamCMD then exits without starting server |
| `L4D2_SERVER_VALIDATE_ONLY_THEN_STOP` | false | Downloads and validates game files via SteamCMD then exits without starting server |
| `L4D2_SERVER_REMOTE_CFG` | (empty) | URL to download config override |
| `L4D2_SERVER_CONFIG` | server.cfg | Config filename to exec |
| `L4D2_SERVER_PW` | (unset) | Server password |
| `L4D2_SERVER_RCONPW` | (unset) | RCON password |

## Config Hierarchy

1. `run.sh` generates a minimal `server.cfg` from env vars (passwords, host info settings)
2. If `L4D2_SERVER_REMOTE_CFG` is set, that URL is downloaded and replaces the config exec target

## Conventions

- Shell scripts use `set -e` for fail-fast
- Numeric env vars are validated with regex before use
- Container runs as non-root `steam` user
- Password env vars are conditionally formatted into config directives (only written if non-empty)
