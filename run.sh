#!/usr/bin/env bash
set -e

echo "


╔═══════════════════════════════════════════════╗
║                                               ║
║       _  _____________      _____   ___       ║
║      / |/ / __/_  __/ | /| / / _ | / _ \      ║
║     /    / _/  / /  | |/ |/ / __ |/ , _/      ║
║    /_/|_/___/ /_/   |__/|__/_/ |_/_/|_|       ║
║                                 OFFICIAL      ║
║                                               ║
╠═══════════════════════════════════════════════╣
║ Thanks for using our DOCKER image! Should you ║
║ have issues, please reach out or create a     ║
║ github issue. Thanks!                         ║
║                                               ║
║ For more information:                         ║
║ github.com/netwarlan                          ║
╚═══════════════════════════════════════════════╝"


## Set default values if none were provided
## ==============================================
L4D2_SERVER_PORT="${L4D2_SERVER_PORT:-27015}"
L4D2_SERVER_MAXPLAYERS="${L4D2_SERVER_MAXPLAYERS:-4}"
L4D2_SERVER_MAP="${L4D2_SERVER_MAP:-c1m1_hotel}"
L4D2_SVLAN="${L4D2_SVLAN:-0}"
L4D2_SERVER_HOSTNAME="${L4D2_SERVER_HOSTNAME:-L4D2 Server}"
L4D2_SERVER_REMOTE_CFG="${L4D2_SERVER_REMOTE_CFG:-}"
L4D2_SERVER_UPDATE_ON_START="${L4D2_SERVER_UPDATE_ON_START:-true}"
L4D2_SERVER_VALIDATE_ON_START="${L4D2_SERVER_VALIDATE_ON_START:-false}"
L4D2_SERVER_UPDATE_ONLY_THEN_STOP="${L4D2_SERVER_UPDATE_ONLY_THEN_STOP:-false}"
L4D2_SERVER_VALIDATE_ONLY_THEN_STOP="${L4D2_SERVER_VALIDATE_ONLY_THEN_STOP:-false}"
L4D2_SERVER_CONFIG="${L4D2_SERVER_CONFIG:-server.cfg}"

## Format password variables for config file
[[ -n "$L4D2_SERVER_PW" ]] && L4D2_SERVER_PW="sv_password $L4D2_SERVER_PW"
[[ -n "$L4D2_SERVER_RCONPW" ]] && L4D2_SERVER_RCONPW="rcon_password $L4D2_SERVER_RCONPW"

## Validate numeric inputs
if [[ ! "$L4D2_SERVER_PORT" =~ ^[0-9]+$ ]]; then
  echo "Error: L4D2_SERVER_PORT must be a valid number"
  exit 1
fi
if [[ ! "$L4D2_SERVER_MAXPLAYERS" =~ ^[0-9]+$ ]]; then
  echo "Error: L4D2_SERVER_MAXPLAYERS must be a valid number"
  exit 1
fi


## Download game files only (without starting server)
## ==============================================
if [[ "$L4D2_SERVER_UPDATE_ONLY_THEN_STOP" = true ]] || [[ "$L4D2_SERVER_VALIDATE_ONLY_THEN_STOP" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading game files only                   ║
╚═══════════════════════════════════════════════╝"
  if [[ "$L4D2_SERVER_VALIDATE_ONLY_THEN_STOP" = true ]]; then
    VALIDATE_FLAG='validate'
  else
    VALIDATE_FLAG=''
  fi

  ## Workaround: https://github.com/ValveSoftware/steam-for-linux/issues/11522
  ## Download with windows platform, then re-run with linux to get correct binaries
  "$STEAMCMD_DIR/steamcmd.sh" \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_update "$STEAMCMD_APP" \
  +quit

  "$STEAMCMD_DIR/steamcmd.sh" \
  +@sSteamCmdForcePlatformType linux \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_update "$STEAMCMD_APP" $VALIDATE_FLAG \
  +quit

echo "
╔═══════════════════════════════════════════════╗
║ Game files downloaded. Stopping container.    ║
╚═══════════════════════════════════════════════╝"
  exit 0
fi


## Update on startup
## ==============================================
if [[ "$L4D2_SERVER_UPDATE_ON_START" = true ]] || [[ "$L4D2_SERVER_VALIDATE_ON_START" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for updates                          ║
╚═══════════════════════════════════════════════╝"
  if [[ "$L4D2_SERVER_VALIDATE_ON_START" = true ]]; then
    VALIDATE_FLAG='validate'
  else
    VALIDATE_FLAG=''
  fi

  ## Workaround: https://github.com/ValveSoftware/steam-for-linux/issues/11522
  ## Download with windows platform, then re-run with linux to get correct binaries
  "$STEAMCMD_DIR/steamcmd.sh" \
  +@sSteamCmdForcePlatformType windows \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_update "$STEAMCMD_APP" \
  +quit

  "$STEAMCMD_DIR/steamcmd.sh" \
  +@sSteamCmdForcePlatformType linux \
  +force_install_dir "$GAME_DIR" \
  +login "$STEAMCMD_USER" "$STEAMCMD_PASSWORD" "$STEAMCMD_AUTH_CODE" \
  +app_update "$STEAMCMD_APP" $VALIDATE_FLAG \
  +quit
fi




## Build server config
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Building server config                        ║
╚═══════════════════════════════════════════════╝"
cat <<EOF > "${GAME_DIR}/left4dead2/cfg/$L4D2_SERVER_CONFIG"
// Values passed from Docker environment
$L4D2_SERVER_PW
$L4D2_SERVER_RCONPW
host_name_store 1
host_info_show 1
host_players_show 2
EOF




## Download config if needed
## ==============================================
if [[ -n "$L4D2_SERVER_REMOTE_CFG" ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading remote config                     ║
╚═══════════════════════════════════════════════╝"
  echo "  Downloading config..."
  L4D2_SERVER_CONFIG=$(basename "$L4D2_SERVER_REMOTE_CFG")
  curl --silent -O --output-dir "$GAME_DIR/left4dead2/cfg/" "$L4D2_SERVER_REMOTE_CFG"
  echo "  Setting $L4D2_SERVER_CONFIG as our server exec"
  chmod 770 "$GAME_DIR/left4dead2/cfg/$L4D2_SERVER_CONFIG"
fi



## Print Variables
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Server set with provided values               ║
╚═══════════════════════════════════════════════╝"
printenv | grep L4D2 || true





## Run
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Starting server                               ║
╚═══════════════════════════════════════════════╝"

## Escaped double quotes help to ensure hostnames with spaces are kept intact
"$GAME_DIR/srcds_run" -game left4dead2 -console -usercon \
+hostname \"${L4D2_SERVER_HOSTNAME}\" \
+exec "$L4D2_SERVER_CONFIG" \
+port "$L4D2_SERVER_PORT" \
+maxplayers "$L4D2_SERVER_MAXPLAYERS" \
+map "$L4D2_SERVER_MAP" \
+sv_lan "$L4D2_SVLAN"