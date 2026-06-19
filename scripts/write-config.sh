#!/usr/bin/env bash
set -euo pipefail

SERVER_DIR="/opt/games/server"
CONFIG_ROOT="/opt/games/config"
SAVED_DIR="${SERVER_DIR}/AbioticFactor/Saved"
WINDOWS_CONFIG_DIR="${SAVED_DIR}/Config/WindowsServer"
ADMIN_DIR="${SAVED_DIR}/SaveGames/Server"
ADMIN_INI="${ADMIN_DIR}/Admin.ini"
SANDBOX_INI="${WINDOWS_CONFIG_DIR}/GNPSandboxSettings.ini"
CONFIG_SANDBOX_COPY="${CONFIG_ROOT}/SandboxSettings.ini"

mkdir -p "${CONFIG_ROOT}" "${ADMIN_DIR}" "${WINDOWS_CONFIG_DIR}"

cat <<EOF
============================================================
📝 Génération configuration Abiotic Factor
➡️ Config root : ${CONFIG_ROOT}
➡️ Admin.ini   : ${ADMIN_INI}
➡️ Sandbox.ini : ${SANDBOX_INI}
============================================================
EOF

# If user provides an Admin.ini in /opt/games/config, sync it to game location.
if [ -f "${CONFIG_ROOT}/Admin.ini" ]; then
    cp "${CONFIG_ROOT}/Admin.ini" "${ADMIN_INI}"
fi

# If game generated Admin.ini, keep a copy visible to GNP.
if [ -f "${ADMIN_INI}" ]; then
    cp "${ADMIN_INI}" "${CONFIG_ROOT}/Admin.ini" || true
fi

if [ "${GNP_WRITE_SANDBOX_CONFIG:-true}" = "true" ]; then
    cat > "${SANDBOX_INI}" <<EOF
[SandboxSettings]
GameDifficulty=${GNP_SANDBOX_GAME_DIFFICULTY:-1}
HardcoreMode=${GNP_SANDBOX_HARDCORE_MODE:-False}
LootRespawnEnabled=${GNP_SANDBOX_LOOT_RESPAWN_ENABLED:-False}
PowerSocketsOffAtNight=${GNP_SANDBOX_POWER_SOCKETS_OFF_AT_NIGHT:-True}
DayNightCycleState=${GNP_SANDBOX_DAY_NIGHT_CYCLE_STATE:-0}
DayNightCycleSpeedMultiplier=${GNP_SANDBOX_DAY_NIGHT_CYCLE_SPEED_MULTIPLIER:-1.0}
WeatherFrequency=${GNP_SANDBOX_WEATHER_FREQUENCY:-3}
SinkRefillRate=${GNP_SANDBOX_SINK_REFILL_RATE:-1.0}
FoodSpoilSpeedMultiplier=${GNP_SANDBOX_FOOD_SPOIL_SPEED_MULTIPLIER:-1.0}
RefrigerationEffectivenessMultiplier=${GNP_SANDBOX_REFRIGERATION_EFFECTIVENESS_MULTIPLIER:-1.0}
StorageByTag=${GNP_SANDBOX_STORAGE_BY_TAG:-True}
StructuralSupportLimit=${GNP_SANDBOX_STRUCTURAL_SUPPORT_LIMIT:-5}
BridgeSupports=${GNP_SANDBOX_BRIDGE_SUPPORTS:-2}
HomeWorlds=${GNP_SANDBOX_HOME_WORLDS:-True}
InvisibleRadiation=${GNP_SANDBOX_INVISIBLE_RADIATION:-False}
TaintedSinkWater=${GNP_SANDBOX_TAINTED_SINK_WATER:-False}
RadiationDealsDamage=${GNP_SANDBOX_RADIATION_DEALS_DAMAGE:-False}
EnemySpawnRate=${GNP_SANDBOX_ENEMY_SPAWN_RATE:-1.0}
EnemyHealthMultiplier=${GNP_SANDBOX_ENEMY_HEALTH_MULTIPLIER:-1.0}
EnemyPlayerDamageMultiplier=${GNP_SANDBOX_ENEMY_PLAYER_DAMAGE_MULTIPLIER:-1.0}
EnemyDeployableDamageMultiplier=${GNP_SANDBOX_ENEMY_DEPLOYABLE_DAMAGE_MULTIPLIER:-1.0}
DetectionSpeedMultiplier=${GNP_SANDBOX_DETECTION_SPEED_MULTIPLIER:-1.0}
EnemyAccuracy=${GNP_SANDBOX_ENEMY_ACCURACY:-2}
DamageToAlliesMultiplier=${GNP_SANDBOX_DAMAGE_TO_ALLIES_MULTIPLIER:-0.5}
HungerSpeedMultiplier=${GNP_SANDBOX_HUNGER_SPEED_MULTIPLIER:-1.0}
ThirstSpeedMultiplier=${GNP_SANDBOX_THIRST_SPEED_MULTIPLIER:-1.0}
FatigueSpeedMultiplier=${GNP_SANDBOX_FATIGUE_SPEED_MULTIPLIER:-1.0}
ContinenceSpeedMultiplier=${GNP_SANDBOX_CONTINENCE_SPEED_MULTIPLIER:-1.0}
BonusPerkPoints=${GNP_SANDBOX_BONUS_PERK_POINTS:-0}
PlayerXPGainMultiplier=${GNP_SANDBOX_PLAYER_XP_GAIN_MULTIPLIER:-1.0}
ItemStackSizeMultiplier=${GNP_SANDBOX_ITEM_STACK_SIZE_MULTIPLIER:-1.0}
ItemWeightMultiplier=${GNP_SANDBOX_ITEM_WEIGHT_MULTIPLIER:-1.0}
ItemDurabilityMultiplier=${GNP_SANDBOX_ITEM_DURABILITY_MULTIPLIER:-1.0}
DurabilityLossOnDeathMultiplier=${GNP_SANDBOX_DURABILITY_LOSS_ON_DEATH_MULTIPLIER:-0.1}
ShowDeathMessages=${GNP_SANDBOX_SHOW_DEATH_MESSAGES:-True}
AllowRecipeSharing=${GNP_SANDBOX_ALLOW_RECIPE_SHARING:-True}
AllowPagers=${GNP_SANDBOX_ALLOW_PAGERS:-True}
AllowTransmog=${GNP_SANDBOX_ALLOW_TRANSMOG:-True}
DisableResearchMinigame=${GNP_SANDBOX_DISABLE_RESEARCH_MINIGAME:-False}
DeathPenalties=${GNP_SANDBOX_DEATH_PENALTIES:-1}
FirstTimeStartingWeapon=${GNP_SANDBOX_FIRST_TIME_STARTING_WEAPON:-0}
HostAccessPlayerCorpses=${GNP_SANDBOX_HOST_ACCESS_PLAYER_CORPSES:-True}
AllowCharacterReset=${GNP_SANDBOX_ALLOW_CHARACTER_RESET:-True}
BaseInventorySize=${GNP_SANDBOX_BASE_INVENTORY_SIZE:-12}
PlayerFurnitureDestruction=${GNP_SANDBOX_PLAYER_FURNITURE_DESTRUCTION:-False}
AllowIronMode=${GNP_SANDBOX_ALLOW_IRON_MODE:-True}
EOF
    cp "${SANDBOX_INI}" "${CONFIG_SANDBOX_COPY}" || true
    echo "✅ SandboxSettings.ini généré."
else
    echo "⏭️ Génération SandboxSettings.ini désactivée."
fi

echo "✅ Configuration prête."
