# Left 4 Dead 2
              
The following repository contains the source files for building a Left 4 Dead 2 server.


### Running
To run the container, issue the following example command:
```
docker run -d \
-p 27015:27015/udp \
-p 27015:27015/tcp \
-e L4D2_SERVER_HOSTNAME="DOCKER L4D2" \
netwarlan/l4d2
```

### Environment Variables
We can make dynamic changes to our L4D2 containers by adjusting some of the environment variables passed to our image.
Below are the ones currently supported and their (defaults):

```
L4D2_SERVER_PORT (27015)
L4D2_SERVER_MAXPLAYERS (8)
L4D2_SERVER_MAP (c1m1_hotel)
L4D2_SERVER_HOSTNAME (L4D2 Server)
L4D2_SERVER_PW (No password set)
L4D2_SERVER_RCONPW (No password set)
L4D2_SERVER_UPDATE_ON_START (false)
```

#### Descriptions

* `L4D2_SERVER_PORT` Determines the port our container runs on.
* `L4D2_SERVER_MAXPLAYERS` Determines the max number of players the * server will allow.
* `L4D2_SERVER_MAP` Determines the starting map.
* `L4D2_SERVER_HOSTNAME` Determines the name of the server.
* `L4D2_SERVER_PW` Determines the password needed to join the server.
* `L4D2_SERVER_RCONPW` Determines the RCON password needed to administer the server.
* `L4D2_SERVER_UPDATE_ON_START` Determines whether the server should update itself to latest when the container starts up.
