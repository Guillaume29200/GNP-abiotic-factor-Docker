#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/gnp
export USER=gnp

STEAMCMD="/opt/steamcmd/steamcmd.sh"
INSTALL_DIR="${GNP_INSTALL_DIR:-/opt/games/server}"
APP_ID="${GNP_STEAM_APP_ID:-2857200}"
STEAM_USER="${GNP_STEAM_USER:-anonymous}"
STEAM_PASSWORD="${GNP_STEAM_PASSWORD:-}"
VALIDATE_ARG=()
PLATFORM_ARG=()

if [ "${GNP_VALIDATE_FILES:-true}" = "true" ]; then
    VALIDATE_ARG=(validate)
fi

# Abiotic Factor Dedicated Server is Windows-only. On Linux SteamCMD, keep this configurable.
# For this AppID, forcing the Windows platform is normally required.
if [ -n "${GNP_STEAM_FORCE_PLATFORM:-}" ]; then
    PLATFORM_ARG=(+@sSteamCmdForcePlatformType "${GNP_STEAM_FORCE_PLATFORM}")
fi

if [ ! -x "$STEAMCMD" ]; then
    echo "❌ SteamCMD introuvable : $STEAMCMD"
    exit 1
fi

mkdir -p "$INSTALL_DIR" /home/gnp/.steam /tmp/dumps

if [ "$STEAM_USER" = "anonymous" ]; then
    LOGIN_ARGS=(+login anonymous)
else
    LOGIN_ARGS=(+login "$STEAM_USER" "$STEAM_PASSWORD")
fi

cat <<EOF
============================================================
📦 Mise à jour SteamCMD / Abiotic Factor
➡️ AppID        : $APP_ID
➡️ Install dir  : $INSTALL_DIR
➡️ SteamCMD     : $STEAMCMD
➡️ User Steam   : $STEAM_USER
➡️ Platform     : ${GNP_STEAM_FORCE_PLATFORM:-windows}
➡️ Validate     : ${GNP_VALIDATE_FILES:-true}
============================================================
EOF

"$STEAMCMD" \
    "${PLATFORM_ARG[@]}" \
    +force_install_dir "$INSTALL_DIR" \
    "${LOGIN_ARGS[@]}" \
    +app_update "$APP_ID" "${VALIDATE_ARG[@]}" \
    +quit

echo "✅ Mise à jour terminée."
