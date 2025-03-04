#!/usr/bin/env bash

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
[[ -z "$L4D2_SERVER_PORT" ]] && L4D2_SERVER_PORT="27015"
[[ -z "$L4D2_SERVER_MAXPLAYERS" ]] && L4D2_SERVER_MAXPLAYERS="4"
[[ -z "$L4D2_SERVER_MAP" ]] && L4D2_SERVER_MAP="c1m1_hotel"
[[ -z "$L4D2_SVLAN" ]] && L4D2_SVLAN="0"
[[ -z "$L4D2_SERVER_HOSTNAME" ]] && L4D2_SERVER_HOSTNAME="L4D2 Server"
[[ ! -z "$L4D2_SERVER_PW" ]] && L4D2_SERVER_PW="sv_password $L4D2_SERVER_PW"
[[ ! -z "$L4D2_SERVER_RCONPW" ]] && L4D2_SERVER_RCONPW="rcon_password $L4D2_SERVER_RCONPW"
[[ -z "$L4D2_SERVER_REMOTE_CFG" ]] && L4D2_SERVER_REMOTE_CFG=""
[[ -z "$L4D2_SERVER_UPDATE_ON_START" ]] && L4D2_SERVER_UPDATE_ON_START=true
[[ -z "$L4D2_SERVER_VALIDATE_ON_START" ]] && L4D2_SERVER_VALIDATE_ON_START=false
[[ -z "$L4D2_SERVER_ENABLE_PROPHUNT" ]] && L4D2_SERVER_ENABLE_PROPHUNT=false
[[ -z "$L4D2_SERVER_CONFIG" ]] && L4D2_SERVER_CONFIG="server.cfg"


## Update on startup
## ==============================================
if [[ "$L4D2_SERVER_UPDATE_ON_START" = true ]] || [[ "$L4D2_SERVER_VALIDATE_ON_START" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for updates                          ║
╚═══════════════════════════════════════════════╝"
  VALIDATE_FLAG=''
  if [[ "$L4D2_SERVER_VALIDATE_ON_START" = true ]]; then
    VALIDATE_FLAG='validate'
  fi

  $STEAMCMD_DIR/steamcmd.sh \
  +force_install_dir $GAME_DIR \
  +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
  +app_update $STEAMCMD_APP $VALIDATE_FLAG \
  +quit
fi




## Build server config
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Building server config                        ║
╚═══════════════════════════════════════════════╝"
cat <<EOF > ${GAME_DIR}/left4dead2/cfg/$L4D2_SERVER_CONFIG
// Values passed from Docker environment
$L4D2_SERVER_PW
$L4D2_SERVER_RCONPW
host_name_store 1
host_info_show 1
host_players_show 2
EOF




## Download config if needed
## ==============================================
if [[ ! -z "$L4D2_SERVER_REMOTE_CFG" ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading remote config                     ║
╚═══════════════════════════════════════════════╝"
  echo "  Downloading config..."
  FILENAME=$(basename "$L4D2_SERVER_REMOTE_CFG")
  curl --silent -O --output-dir $GAME_DIR/left4dead2/cfg/ $L4D2_SERVER_REMOTE_CFG
  chmod 770 $GAME_DIR/left4dead2/cfg/$FILENAME
  echo "  Setting $FILENAME as our server exec"
  L4D2_SERVER_CONFIG=$FILENAME
fi



## Print Variables
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Server set with provided values               ║
╚═══════════════════════════════════════════════╝"
printenv | grep L4D2





## Run
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Starting server                               ║
╚═══════════════════════════════════════════════╝"

## Escaped double quotes help to ensure hostnames with spaces are kept intact
$GAME_DIR/srcds_run -game left4dead2 -console -usercon \
+hostname \"${L4D2_SERVER_HOSTNAME}\" \
+exec $L4D2_SERVER_CONFIG \
+port $L4D2_SERVER_PORT \
+maxplayers $L4D2_SERVER_MAXPLAYERS \
+map $L4D2_SERVER_MAP \
+sv_lan $L4D2_SVLAN