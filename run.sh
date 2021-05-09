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
║ a github issue. Thanks!                       ║
║                                               ║
║ For more information:                         ║
║ https://github.com/netwarlan                  ║
╚═══════════════════════════════════════════════╝
"

## Startup
[[ -z "$L4D2_SERVER_PORT" ]] && L4D2_SERVER_PORT="27015"
[[ -z "$L4D2_SERVER_MAXPLAYERS" ]] && L4D2_SERVER_MAXPLAYERS="24"
[[ -z "$L4D2_SERVER_MAP" ]] && L4D2_SERVER_MAP="c1m1_hotel"

## Config
[[ -z "$L4D2_SERVER_HOSTNAME" ]] && L4D2_SERVER_HOSTNAME="L4D2 Server"
[[ ! -z "$L4D2_SERVER_PW" ]] && L4D2_SERVER_PW="sv_password $L4D2_SERVER_PW"
[[ ! -z "$L4D2_SERVER_RCONPW" ]] && L4D2_SERVER_RCONPW="rcon_password $L4D2_SERVER_RCONPW"

cat <<EOF >$GAME_DIR/left4dead2/cfg/server.cfg
hostname $L4D2_SERVER_HOSTNAME
$L4D2_SERVER_PW
$L4D2_SERVER_RCONPW
EOF


## Update
if [[ "$L4D2_SERVER_UPDATE_ON_START" = true ]];
then
echo "
╔═══════════════════════════════════════════════╗
║ Checking for Updates                          ║
╚═══════════════════════════════════════════════╝
"
$STEAMCMD_DIR/steamcmd.sh \
+login $STEAMCMD_USER $STEAMCMD_PASSWORD $STEAMCMD_AUTH_CODE \
+force_install_dir $GAME_DIR \
+app_update $STEAMCMD_APP validate \
+quit

echo "
╔═══════════════════════════════════════════════╗
║ SERVER up to date                             ║
╚═══════════════════════════════════════════════╝
"
fi

## Run
echo "
╔═══════════════════════════════════════════════╗
║ Starting SERVER                               ║
╚═══════════════════════════════════════════════╝
"
$GAME_DIR/srcds_run -game left4dead2 -console -usercon +port $L4D2_SERVER_PORT +maxplayers $L4D2_SERVER_MAXPLAYERS +map $L4D2_SERVER_MAP +sv_lan 1 -secure
