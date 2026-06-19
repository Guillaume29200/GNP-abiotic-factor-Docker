# 🐳 Abiotic Factor Dedicated Server - GNP Standard

## 📌 Description

Image Docker dédiée au serveur **Abiotic Factor**, entièrement standardisée pour l'écosystème **GameNodePanel (GNP)**.

Cette image permet de déployer facilement un serveur Abiotic Factor sous Linux via **Wine + SteamCMD**, avec gestion automatique de l'installation, des mises à jour, de la configuration sandbox et des paramètres de lancement avancés.

---

## 🚀 Features

- Installation automatique via SteamCMD
- Support Wine + Xvfb (serveur Windows sous Linux)
- Ordre SteamCMD corrigé pour AppID Windows-only
- Mise à jour automatique du serveur
- Logs propres via `echo` comme les autres images GNP
- Paramètres de lancement avancés officiels
- Limitation de plateforme : `PC`, `Xbox`, `Playstation` ou crossplay
- Génération automatique de `SandboxSettings.ini`
- Variables GNP unifiées (`GNP_*`)
- Structure standard pour tous les jeux GNP
- Compatible Docker, VPS et serveur dédié
- Healthcheck Docker intégré

---

## 📁 Structure GNP

```txt
/opt/steamcmd         -> SteamCMD (persistant)
/opt/games/server     -> Fichiers du serveur
/opt/games/config     -> Configuration externe lisible par GNP
/opt/wine             -> Environnement Wine
/home/gnp             -> HOME utilisateur SteamCMD/Wine
```

---

## ⚙️ Variables d'environnement (GNP)

### 🔧 Général

```env
GNP_TZ=Europe/Paris
GNP_PUID=1000
GNP_PGID=1000
```

---

### 📦 Steam

```env
GNP_STEAM_APP_ID=2857200
GNP_STEAM_USER=anonymous
GNP_STEAM_PASSWORD=

GNP_GAME_UPDATE=true
GNP_VALIDATE_FILES=false
GNP_STEAM_FORCE_PLATFORM=windows
```

> Abiotic Factor Dedicated Server est Windows-only. Sous Linux, `GNP_STEAM_FORCE_PLATFORM=windows` permet de forcer SteamCMD à récupérer le dépôt Windows.
>
> `GNP_VALIDATE_FILES=false` par défaut pour éviter une validation complète à chaque redémarrage. Passer à `true` uniquement si des fichiers sont corrompus.

---

### 🎮 Serveur Abiotic Factor

```env
GNP_SERVER_NAME=GNP Abiotic Factor Server
GNP_SERVER_PASSWORD=
GNP_ADMIN_PASSWORD=
GNP_MAX_PLAYERS=6
GNP_WORLD_SAVE_NAME=Cascade
```

> Le maximum officiel est 24 joueurs, mais au-dessus de 6 joueurs le jeu peut afficher un avertissement côté client.
>
> ⚠️ `GNP_ADMIN_PASSWORD` est vide par défaut. Définir une valeur avant de déployer.

---

### 🌐 Réseau

```env
GNP_GAME_PORT=7777
GNP_QUERY_PORT=27015
```

Ports à publier :

```txt
7777/udp   -> Game Port
27015/udp  -> Steam Query Port
14001/udp  -> LAN discovery si GNP_LAN_ONLY=true
```

---

### ⚙️ Paramètres avancés officiels

```env
GNP_USE_PERF_THREADS=true
GNP_DISABLE_ASYNC_LOADING_THREAD=false
GNP_NO_ASYNC_LOADING_THREAD=false
GNP_LAN_ONLY=false

# Vide = crossplay activé
# Valeurs possibles : PC, Playstation, Xbox
GNP_PLATFORM_LIMITED=

GNP_MULTIHOME=
GNP_USE_LOCAL_IPS=false

GNP_SANDBOX_INI_PATH=Config/WindowsServer/GNPSandboxSettings.ini
GNP_ADMIN_INI_PATH=
GNP_START_ARGS=
```

Exemples :

```env
# Steam uniquement / PC uniquement
GNP_PLATFORM_LIMITED=PC

# Playstation uniquement
GNP_PLATFORM_LIMITED=Playstation

# Xbox + Windows Store uniquement
GNP_PLATFORM_LIMITED=Xbox
```

---

### 🧪 Sandbox Settings

L'image peut générer automatiquement :

```txt
/opt/games/server/AbioticFactor/Saved/Config/WindowsServer/GNPSandboxSettings.ini
/opt/games/config/SandboxSettings.ini
```

Variables principales :

```env
GNP_WRITE_SANDBOX_CONFIG=true
GNP_SANDBOX_GAME_DIFFICULTY=1
GNP_SANDBOX_HARDCORE_MODE=False
GNP_SANDBOX_LOOT_RESPAWN_ENABLED=False
GNP_SANDBOX_POWER_SOCKETS_OFF_AT_NIGHT=True
GNP_SANDBOX_DAY_NIGHT_CYCLE_STATE=0
GNP_SANDBOX_DAY_NIGHT_CYCLE_SPEED_MULTIPLIER=1.0
GNP_SANDBOX_WEATHER_FREQUENCY=3
GNP_SANDBOX_ENEMY_SPAWN_RATE=1.0
GNP_SANDBOX_ENEMY_HEALTH_MULTIPLIER=1.0
GNP_SANDBOX_ENEMY_PLAYER_DAMAGE_MULTIPLIER=1.0
GNP_SANDBOX_DAMAGE_TO_ALLIES_MULTIPLIER=0.5
GNP_SANDBOX_PLAYER_XP_GAIN_MULTIPLIER=1.0
GNP_SANDBOX_ITEM_STACK_SIZE_MULTIPLIER=1.0
GNP_SANDBOX_ITEM_WEIGHT_MULTIPLIER=1.0
GNP_SANDBOX_DEATH_PENALTIES=1
```

Toutes les variables sandbox complètes sont listées dans `env.example`.

---

### 🧠 Wine / Display

```env
GNP_USE_WINE=true
GNP_WINEPREFIX=/opt/wine/abiotic-factor
GNP_WINEARCH=win64
GNP_DISPLAY=:99
GNP_XVFB_RESOLUTION=1024x768x16
GNP_WINEDEBUG=-all
```

---

### ⚙️ Exécution

```env
GNP_SERVER_EXE=AbioticFactorServer-Win64-Shipping.exe
GNP_START_ARGS=
```

---

## 💾 Volumes

```yaml
volumes:
  - ./data/server:/opt/games/server
  - ./data/config:/opt/games/config
  - ./data/wine:/opt/wine
  - ./data/steamcmd:/opt/steamcmd
```

---

## ▶️ Exemple docker-compose

```yaml
services:
  abiotic-factor:
    image: slymer29/gnp-abiotic-factor:latest
    container_name: gnp-abiotic-factor
    restart: unless-stopped
    stop_grace_period: 30s

    ports:
      - "7777:7777/udp"
      - "27015:27015/udp"
      - "14001:14001/udp"

    environment:
      GNP_SERVER_NAME: "Mon serveur Abiotic Factor"
      GNP_SERVER_PASSWORD: ""
      GNP_ADMIN_PASSWORD: ""
      GNP_MAX_PLAYERS: "6"
      GNP_GAME_PORT: "7777"
      GNP_QUERY_PORT: "27015"
      GNP_PLATFORM_LIMITED: ""

    volumes:
      - ./data/server:/opt/games/server
      - ./data/config:/opt/games/config
      - ./data/wine:/opt/wine
      - ./data/steamcmd:/opt/steamcmd
```

---

## 🧪 Variables panel GNP recommandées

```env
GNP_GAME_UPDATE=true
GNP_VALIDATE_FILES=false
GNP_STEAM_APP_ID=2857200
GNP_STEAM_USER=anonymous
GNP_STEAM_PASSWORD=
GNP_STEAM_FORCE_PLATFORM=windows

GNP_SERVER_NAME={server_name}
GNP_SERVER_PASSWORD=
GNP_ADMIN_PASSWORD=
GNP_MAX_PLAYERS={slots}
GNP_WORLD_SAVE_NAME=Cascade

GNP_GAME_PORT={port}
GNP_QUERY_PORT={query_port}

GNP_PLATFORM_LIMITED=
GNP_USE_PERF_THREADS=true
GNP_DISABLE_ASYNC_LOADING_THREAD=false
GNP_LAN_ONLY=false
GNP_SANDBOX_INI_PATH=Config/WindowsServer/GNPSandboxSettings.ini
GNP_WRITE_SANDBOX_CONFIG=true

GNP_USE_WINE=true
GNP_WINEPREFIX=/opt/wine/abiotic-factor
GNP_WINEARCH=win64
GNP_DISPLAY=:99
GNP_XVFB_RESOLUTION=1024x768x16
GNP_WINEDEBUG=-all

GNP_SERVER_EXE=AbioticFactorServer-Win64-Shipping.exe
GNP_START_ARGS=
```

---

## ⚠️ Important

- Abiotic Factor Dedicated Server est actuellement Windows-only.
- Le premier démarrage peut être long : téléchargement SteamCMD + initialisation Wine.
- L'image ne contient pas les fichiers du jeu.
- Les fichiers sont téléchargés automatiquement au premier lancement.
- Ne pas utiliser `-NOSTEAM` pour un serveur normal.
- `GNP_PLATFORM_LIMITED=PC` désactive le crossplay et limite le serveur aux joueurs Steam.
- `GNP_ADMIN_PASSWORD` est vide par défaut — à définir impérativement avant mise en production.

---

## 🔎 Exécutable Abiotic Factor

L'image utilise par défaut :

```env
GNP_SERVER_EXE=AbioticFactorServer-Win64-Shipping.exe
```

C'est le nom officiel fourni par SteamCMD. Le script possède également des fallbacks automatiques :

```txt
1. ${SERVER_DIR}/${GNP_SERVER_EXE}
2. ${SERVER_DIR}/AbioticFactor/Binaries/Win64/${GNP_SERVER_EXE}
3. ${SERVER_DIR}/AbioticFactorServer.exe
4. ${SERVER_DIR}/AbioticFactor/Binaries/Win64/AbioticFactorServer-Win64-Shipping.exe
```

Cela évite tout crash si la structure du jeu change entre deux mises à jour Steam.

---

## 🧠 Wine / Xvfb

Xvfb est démarré en premier, puis le script attend jusqu'à 30 secondes que le display soit accessible avant d'initialiser Wine. `wineboot --init` est ignoré si le prefix Wine existe déjà, ce qui accélère les redémarrages.

Pour débugger Wine :

```env
GNP_WINEDEBUG=warn+all
```

Par défaut `GNP_WINEDEBUG=-all` masque les logs très verbeux de Wine.

---

## 🎯 Intégration GameNodePanel

Cette image suit le standard GNP :

- Variables unifiées (`GNP_*`)
- Structure identique pour tous les jeux
- Déploiement automatisé
- Logs clairs pour le panel
- Gestion sandbox prête pour un futur formulaire avancé

---

## 🔥 Auteur

Image maintenue par **slymer29**

Optimisée pour l'écosystème **GameNodePanel (GNP)**
