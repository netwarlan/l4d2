# Left 4 Dead 2            
The following repository contains the source files for building a Left 4 Dead 2 server.


### Running
To run the container, issue the following example command:
```
docker run -d \
-p 27015:27015/udp \
-p 27015:27015/tcp \
-e L4D2_SERVER_HOSTNAME="DOCKER L4D2" \
ghcr.io/netwarlan/l4d2
```

### SteamCMD Download/Install Issues
Starting 11/27/2024, Valve removed L4D2 from the Anonymous Dedicated Server distribution list. More info here: https://github.com/ValveSoftware/steam-for-linux/issues/11522

For this to work going forward, a username and password will need to be provided.

You can pass this to docker environment variables:
```
STEAMCMD_USER="your-username"
STEAMCMD_PASSWORD="your-password"
STEAMCMD_AUTH_CODE="ABC123"
```
* The above can be passed via `docker run`, or part of your `compose.yaml` both methods allow setting environment variables and passing them into the container via `.env`
* If you have MFA enabled on the account, you may also need to manually "Approve" the login request


### Environment Variables
We can make dynamic changes to our L4D2 containers by adjusting some of the environment variables passed to our image.
Below are the ones currently supported and their (defaults):

Environment Variable | Default Value
-------------------- | -------------
L4D2_SERVER_PORT | 27015
L4D2_SERVER_MAXPLAYERS | 4
L4D2_SERVER_MAP | c1m1_hotel
L4D2_SERVER_HOSTNAME | L4D2 Server
L4D2_SVLAN | 0
L4D2_SERVER_RCONPW | No password set
L4D2_SERVER_UPDATE_ON_START | true
L4D2_SERVER_VALIDATE_ON_START | false
L4D2_SERVER_ENABLE_REMOTE_CFG | false
L4D2_SERVER_REMOTE_CFG | No url set