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
╚═══════════════════════════════════════════════╝
"


## Set default values if none were provided
## ==============================================
[[ -z "$L4D2_SERVER_PORT" ]] && L4D2_SERVER_PORT="27015"
[[ -z "$L4D2_SERVER_MAXPLAYERS" ]] && L4D2_SERVER_MAXPLAYERS="4"
[[ -z "$L4D2_SERVER_MAP" ]] && L4D2_SERVER_MAP="c1m1_hotel"
[[ -z "$L4D2_SVLAN" ]] && L4D2_SVLAN="0"
[[ -z "$L4D2_SERVER_HOSTNAME" ]] && L4D2_SERVER_HOSTNAME="L4D2 Server"
[[ ! -z "$L4D2_SERVER_PW" ]] && L4D2_SERVER_PW="sv_password $L4D2_SERVER_PW"
[[ ! -z "$L4D2_SERVER_RCONPW" ]] && L4D2_SERVER_RCONPW="rcon_password $L4D2_SERVER_RCONPW"
[[ -z "$L4D2_SERVER_ENABLE_REMOTE_CFG" ]] && L4D2_SERVER_ENABLE_REMOTE_CFG=false
[[ -z "$L4D2_SERVER_UPDATE_ON_START" ]] && L4D2_SERVER_UPDATE_ON_START=true
[[ -z "$L4D2_SERVER_VALIDATE_ON_START" ]] && L4D2_SERVER_VALIDATE_ON_START=false




## Update on startup
## ==============================================
if [[ "$L4D2_SERVER_UPDATE_ON_START" = true ]] || [[ "$L4D2_SERVER_VALIDATE_ON_START" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for updates                          ║
╚═══════════════════════════════════════════════╝
"
  if [[ "$L4D2_SERVER_VALIDATE_ON_START" = true ]]; then
    VALIDATE_FLAG='validate'
  else 
    VALIDATE_FLAG=''
  fi

  $STEAMCMD_DIR/steamcmd.sh \
  +login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
  +force_install_dir $GAME_DIR \
  +app_update $STEAMCMD_APP $VALIDATE_FLAG \
  +quit

fi





## Download config if needed
## ==============================================
if [[ "$L4D2_SERVER_ENABLE_REMOTE_CFG" = true ]]; then
echo "
╔═══════════════════════════════════════════════╗
║ Downloading remote config                     ║
╚═══════════════════════════════════════════════╝
"
  if [[ -z "$L4D2_SERVER_REMOTE_CFG" ]]; then
    echo "  Remote config enabled, but no URL provided..."
  else
    echo "  Downloading config..."
    wget -q $L4D2_SERVER_REMOTE_CFG -O $GAME_DIR/left4dead2/cfg/server.cfg
  fi

fi




## Build server config
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Building server config                        ║
╚═══════════════════════════════════════════════╝
"
cat <<EOF >> $GAME_DIR/left4dead2/cfg/server.cfg
// Values passed from Docker environment
$L4D2_SERVER_PW
$L4D2_SERVER_RCONPW
EOF





## Run
## ==============================================
echo "
╔═══════════════════════════════════════════════╗
║ Starting server                               ║
╚═══════════════════════════════════════════════╝
  Hostname: $L4D2_SERVER_HOSTNAME
  Port: $L4D2_SERVER_PORT
  Max Players: $L4D2_SERVER_MAXPLAYERS
  Map: $L4D2_SERVER_MAP
"

$GAME_DIR/srcds_run -game left4dead2 -console -usercon +hostname \"${L4D2_SERVER_HOSTNAME}\" +port $L4D2_SERVER_PORT +maxplayers $L4D2_SERVER_MAXPLAYERS +map $L4D2_SERVER_MAP +sv_lan $L4D2_SVLAN