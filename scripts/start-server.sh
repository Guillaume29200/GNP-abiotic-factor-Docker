#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="/opt/games/server"
REQUESTED_EXE="${GNP_SERVER_EXE:-AbioticFactorServer.exe}"
EXE_PATH=""

export HOME=/home/gnp
export USER=gnp
export WINEPREFIX="${GNP_WINEPREFIX}"
export WINEARCH="${GNP_WINEARCH}"
export DISPLAY="${GNP_DISPLAY}"
export WINEDEBUG="${GNP_WINEDEBUG:--all}"

mkdir -p "${WINEPREFIX}" /tmp/.X11-unix /tmp/dumps

cat <<EOF
============================================================
🖥️ Démarrage Xvfb
➡️ Display    : ${DISPLAY}
➡️ Resolution : ${GNP_XVFB_RESOLUTION}
============================================================
EOF

Xvfb "${DISPLAY}" -screen 0 "${GNP_XVFB_RESOLUTION}" -nolisten tcp >/tmp/xvfb-abiotic.log 2>&1 &
XVFB_PID=$!

cleanup() {
    echo "🛑 Arrêt Abiotic Factor / Xvfb..."
    kill "${XVFB_PID}" >/dev/null 2>&1 || true
}
trap cleanup EXIT INT TERM

for i in $(seq 1 30); do
    if xdpyinfo -display "${DISPLAY}" >/dev/null 2>&1; then
        echo "✅ Xvfb prêt."
        break
    fi
    sleep 1
    if [ "$i" = "30" ]; then
        echo "❌ Xvfb n'est pas prêt après 30 secondes."
        cat /tmp/xvfb-abiotic.log || true
        exit 1
    fi
done

cat <<EOF
============================================================
🍷 Initialisation Wine
➡️ WINEPREFIX : ${WINEPREFIX}
➡️ WINEARCH   : ${WINEARCH}
➡️ WINEDEBUG  : ${WINEDEBUG}
============================================================
EOF

if [ ! -f "${WINEPREFIX}/system.reg" ]; then
    wineboot --init >/tmp/wineboot-abiotic.log 2>&1 || true
else
    echo "✅ Wine prefix déjà initialisé, wineboot ignoré."
fi

cat <<EOF
============================================================
🔎 Recherche exécutable Abiotic Factor
➡️ Demandé : ${REQUESTED_EXE}
============================================================
EOF

CANDIDATES=()

if [[ "${REQUESTED_EXE}" = /* ]]; then
    CANDIDATES+=("${REQUESTED_EXE}")
else
    CANDIDATES+=("${SERVER_DIR}/${REQUESTED_EXE}")
    CANDIDATES+=("${SERVER_DIR}/AbioticFactor/Binaries/Win64/${REQUESTED_EXE}")
fi

# Fallbacks connus depuis les builds actuels SteamCMD.
CANDIDATES+=("${SERVER_DIR}/AbioticFactorServer.exe")
CANDIDATES+=("${SERVER_DIR}/AbioticFactor/Binaries/Win64/AbioticFactorServer-Win64-Shipping.exe")

for candidate in "${CANDIDATES[@]}"; do
    echo "➡️ Test exe : ${candidate}"
    if [ -f "${candidate}" ]; then
        EXE_PATH="${candidate}"
        break
    fi
done

if [ -z "${EXE_PATH}" ]; then
    echo "❌ Aucun exécutable Abiotic Factor valide trouvé."
    echo "➡️ Steam update peut avoir échoué ou la structure du jeu a changé."
    echo "➡️ Exécutables trouvés :"
    find "${SERVER_DIR}" -maxdepth 7 -type f -iname "*.exe" | sort || true
    exit 1
fi

echo "✅ Exécutable utilisé : ${EXE_PATH}"

ARGS=()
ARGS+=("-log")
ARGS+=("-newconsole")

if [ "${GNP_USE_PERF_THREADS:-true}" = "true" ]; then
    ARGS+=("-useperfthreads")
fi

if [ "${GNP_DISABLE_ASYNC_LOADING_THREAD:-false}" = "true" ]; then
    ARGS+=("-DisableAsyncLoadingThread")
elif [ "${GNP_NO_ASYNC_LOADING_THREAD:-false}" = "true" ]; then
    # Ancien paramètre conservé pour compatibilité avec les anciens templates GNP.
    ARGS+=("-NoAsyncLoadingThread")
fi

if [ "${GNP_LAN_ONLY:-false}" = "true" ]; then
    ARGS+=("-LANOnly")
fi

if [ "${GNP_USE_LOCAL_IPS:-false}" = "true" ]; then
    ARGS+=("-UseLocalIPs")
fi

if [ -n "${GNP_PLATFORM_LIMITED:-}" ]; then
    ARGS+=("-PlatformLimited=${GNP_PLATFORM_LIMITED}")
fi

if [ -n "${GNP_MULTIHOME:-}" ]; then
    ARGS+=("-MultiHome=${GNP_MULTIHOME}")
fi

ARGS+=("-MaxServerPlayers=${GNP_MAX_PLAYERS}")
ARGS+=("-PORT=${GNP_GAME_PORT}")
ARGS+=("-QueryPort=${GNP_QUERY_PORT}")

if [ -n "${GNP_SERVER_PASSWORD:-}" ]; then
    ARGS+=("-ServerPassword=${GNP_SERVER_PASSWORD}")
fi

if [ -n "${GNP_ADMIN_PASSWORD:-}" ]; then
    ARGS+=("-AdminPassword=${GNP_ADMIN_PASSWORD}")
fi

ARGS+=("-SteamServerName=${GNP_SERVER_NAME}")
ARGS+=("-WorldSaveName=${GNP_WORLD_SAVE_NAME}")

if [ -n "${GNP_SANDBOX_INI_PATH:-}" ]; then
    ARGS+=("-SandboxIniPath=${GNP_SANDBOX_INI_PATH}")
fi

if [ -n "${GNP_ADMIN_INI_PATH:-}" ]; then
    ARGS+=("-AdminIniPath=${GNP_ADMIN_INI_PATH}")
fi

if [ -n "${GNP_START_ARGS:-}" ]; then
    # shellcheck disable=SC2206
    EXTRA_ARGS=( ${GNP_START_ARGS} )
    ARGS+=("${EXTRA_ARGS[@]}")
fi

cat <<EOF
============================================================
🎮 Démarrage Abiotic Factor Dedicated Server
➡️ Server dir      : ${SERVER_DIR}
➡️ Exe             : ${EXE_PATH}
➡️ Wine prefix     : ${WINEPREFIX}
➡️ Display         : ${DISPLAY}
➡️ Server name     : ${GNP_SERVER_NAME}
➡️ World save      : ${GNP_WORLD_SAVE_NAME}
➡️ Max players     : ${GNP_MAX_PLAYERS}
➡️ Game port       : ${GNP_GAME_PORT}/udp
➡️ Query port      : ${GNP_QUERY_PORT}/udp
➡️ Platform limit  : ${GNP_PLATFORM_LIMITED:-crossplay}
➡️ Sandbox ini     : ${GNP_SANDBOX_INI_PATH:-default world file}
➡️ Start args      : ${GNP_START_ARGS:-}
============================================================
EOF

cd "$(dirname "${EXE_PATH}")"

printf '➡️ Commande finale : wine %q ' "${EXE_PATH}"
printf '%q ' "${ARGS[@]}"
echo

exec wine "${EXE_PATH}" "${ARGS[@]}"
