#!/usr/bin/env bash
set -euo pipefail

export HOME=/home/gnp
export USER=gnp

# Lowercase aliases for GNP if needed
export GNP_TZ="${GNP_TZ:-${gnp_tz:-Europe/Paris}}"
export GNP_PUID="${GNP_PUID:-${gnp_puid:-1000}}"
export GNP_PGID="${GNP_PGID:-${gnp_pgid:-1000}}"

export GNP_STEAM_APP_ID="${GNP_STEAM_APP_ID:-${gnp_steam_app_id:-2857200}}"
export GNP_STEAM_USER="${GNP_STEAM_USER:-${gnp_steam_user:-anonymous}}"
export GNP_STEAM_PASSWORD="${GNP_STEAM_PASSWORD:-${gnp_steam_password:-}}"
export GNP_GAME_UPDATE="${GNP_GAME_UPDATE:-${gnp_game_update:-true}}"
export GNP_VALIDATE_FILES="${GNP_VALIDATE_FILES:-${gnp_validate_files:-true}}"
export GNP_STEAM_FORCE_PLATFORM="${GNP_STEAM_FORCE_PLATFORM:-${gnp_steam_force_platform:-windows}}"

export GNP_SERVER_NAME="${GNP_SERVER_NAME:-${gnp_server_name:-GNP Abiotic Factor Server}}"
export GNP_SERVER_PASSWORD="${GNP_SERVER_PASSWORD:-${gnp_server_password:-}}"
export GNP_ADMIN_PASSWORD="${GNP_ADMIN_PASSWORD:-${gnp_admin_password:-}}"
export GNP_MAX_PLAYERS="${GNP_MAX_PLAYERS:-${gnp_max_players:-6}}"
export GNP_WORLD_SAVE_NAME="${GNP_WORLD_SAVE_NAME:-${gnp_world_save_name:-Cascade}}"

export GNP_GAME_PORT="${GNP_GAME_PORT:-${gnp_game_port:-7777}}"
export GNP_QUERY_PORT="${GNP_QUERY_PORT:-${gnp_query_port:-27015}}"

export GNP_USE_PERF_THREADS="${GNP_USE_PERF_THREADS:-${gnp_use_perf_threads:-true}}"
export GNP_DISABLE_ASYNC_LOADING_THREAD="${GNP_DISABLE_ASYNC_LOADING_THREAD:-${gnp_disable_async_loading_thread:-false}}"
export GNP_NO_ASYNC_LOADING_THREAD="${GNP_NO_ASYNC_LOADING_THREAD:-${gnp_no_async_loading_thread:-false}}"
export GNP_LAN_ONLY="${GNP_LAN_ONLY:-${gnp_lan_only:-false}}"
export GNP_PLATFORM_LIMITED="${GNP_PLATFORM_LIMITED:-${gnp_platform_limited:-}}"
export GNP_MULTIHOME="${GNP_MULTIHOME:-${gnp_multihome:-}}"
export GNP_USE_LOCAL_IPS="${GNP_USE_LOCAL_IPS:-${gnp_use_local_ips:-false}}"
export GNP_SANDBOX_INI_PATH="${GNP_SANDBOX_INI_PATH:-${gnp_sandbox_ini_path:-Config/WindowsServer/GNPSandboxSettings.ini}}"
export GNP_ADMIN_INI_PATH="${GNP_ADMIN_INI_PATH:-${gnp_admin_ini_path:-}}"
export GNP_WRITE_SANDBOX_CONFIG="${GNP_WRITE_SANDBOX_CONFIG:-${gnp_write_sandbox_config:-true}}"

export GNP_USE_WINE="${GNP_USE_WINE:-${gnp_use_wine:-true}}"
export GNP_WINEPREFIX="${GNP_WINEPREFIX:-${gnp_wineprefix:-/opt/wine/abiotic-factor}}"
export GNP_WINEARCH="${GNP_WINEARCH:-${gnp_winearch:-win64}}"
export GNP_DISPLAY="${GNP_DISPLAY:-${gnp_display:-:99}}"
export GNP_XVFB_RESOLUTION="${GNP_XVFB_RESOLUTION:-${gnp_xvfb_resolution:-1024x768x16}}"
export GNP_WINEDEBUG="${GNP_WINEDEBUG:-${gnp_winedebug:--all}}"

export GNP_SERVER_EXE="${GNP_SERVER_EXE:-${gnp_server_exe:-AbioticFactorServer.exe}}"
export GNP_START_ARGS="${GNP_START_ARGS:-${gnp_start_args:-}}"

ln -snf "/usr/share/zoneinfo/${GNP_TZ}" /etc/localtime || true
echo "${GNP_TZ}" > /etc/timezone || true

if [ "$(id -u gnp)" != "${GNP_PUID}" ]; then
    usermod -u "${GNP_PUID}" gnp
fi

if [ "$(id -g gnp)" != "${GNP_PGID}" ]; then
    groupmod -g "${GNP_PGID}" gnp
fi

mkdir -p /opt/steamcmd /opt/games/server /opt/games/config /opt/wine /home/gnp /tmp/.X11-unix /tmp/dumps
chmod 1777 /tmp/.X11-unix || true
chown -R gnp:gnp /opt/steamcmd /opt/games /opt/wine /home/gnp /tmp/dumps

cat <<EOF
============================================================
🚀 Démarrage image GNP - Abiotic Factor
➡️ User       : GNP (${GNP_PUID}:${GNP_PGID})
➡️ HOME       : /home/gnp
➡️ Server dir : /opt/games/server
➡️ Config dir : /opt/games/config
➡️ SteamCMD   : /opt/steamcmd
➡️ Wine prefix: ${GNP_WINEPREFIX}
➡️ Display    : ${GNP_DISPLAY}
============================================================
EOF

if [ "${GNP_GAME_UPDATE}" = "true" ]; then
    gosu gnp /scripts/steam-update.sh
else
    echo "⏭️ Mise à jour SteamCMD désactivée (GNP_GAME_UPDATE=false)."
fi

gosu gnp /scripts/write-config.sh

exec gosu gnp /scripts/start-server.sh
