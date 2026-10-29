# Fikua private Minecraft server — vanilla Java Edition.
#
# Thin layer over itzg/minecraft-server, which downloads Mojang's official
# server.jar for VERSION on first start. The base is pinned by digest so
# upstream changes only land through a reviewed Dependabot PR.
#
# Only non-sensitive, versioned server settings live here. Anything
# private (who may join, RCON password, the address the port binds to)
# comes from repo secrets at deploy time — see compose.yaml and
# .github/workflows/deploy.yml. This repo and its image are public.
FROM itzg/minecraft-server:java25@sha256:2bdb73827c0dbb0444ca2e8a25240c4837bc47b7f44975c2547bb6daf503212b

# Bumping VERSION is a deliberate, reviewed change: a world saved by a
# newer version never opens on an older one, so it only ever goes up,
# after a backup, with every launcher moved to the same version.
ENV EULA=TRUE \
    TYPE=VANILLA \
    VERSION=26.3 \
    USE_AIKAR_FLAGS=true \
    TZ=Europe/Madrid \
    ONLINE_MODE=true \
    ENABLE_WHITELIST=true \
    ENFORCE_WHITELIST=true \
    MODE=survival \
    DIFFICULTY=normal \
    VIEW_DISTANCE=10 \
    SIMULATION_DISTANCE=8 \
    ENABLE_RCON=true \
    MOTD="Fikua — servidor privat"
