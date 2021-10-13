# Minecraft Docker-Compose managed server

## Commands and server terminal access

To exec/run commands on the minecraft server, use:

```sh
docker exec -i minecraft rcon-cli
```

OR use with a single command, such as `stop` to stop the running server

```sh
docker exec minecraft rcon-cli stop
```

## Upgrading

When using `VERSION=LATEST` such as this server, simply restart the container to re-pull the latest image and automatically update to the newest version available.


