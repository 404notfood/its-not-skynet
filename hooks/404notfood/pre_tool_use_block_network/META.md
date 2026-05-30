# Meta - pre_tool_use_block_network

## Source
- Auteur : 404notfood
- Repo : https://github.com/Baylox/its-not-skynet
- Statut : **Cree par moi**

## Contexte d'usage
Empêche l'agent d'exécuter automatiquement des commandes qui contactent un réseau externe, téléchargent des dépendances ou lancent du code distant sans validation humaine.

Le hook bloque notamment :

- accès réseau directs : `curl`, `wget`, `aria2c`, `http`, `https`, `ftp`, `nc`, `telnet`
- opérations Git distantes : `git clone`, `git fetch`, `git pull`, `git ls-remote`, `git submodule update --init`
- registres JS : `npm install`, `npm i`, `npm exec`, `npx`, `pnpm add/install/dlx`, `yarn add/install/dlx`, `bun add/install/x`
- registres Python : `pip install`, `pip download`, `pipx install`, `pipx run`, `uv add/sync/tool run`
- autres gestionnaires : `composer install/update/require`, `cargo install/update`, `go get/install`
- Docker : `docker pull`, `docker run`, `docker buildx build`

Déterministe, pur shell, **aucun accès réseau**. Le hook ne fournit pas de bypass dans la commande elle-même : si l'action est réellement voulue, l'humain doit l'exécuter manuellement après vérification de la source.

## Événement
- `PreToolUse` - matcher : `Bash`
- Exit 2 = blocage avec message dans stderr

## Installation

### Ajouter dans settings.json :
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"$CLAUDE_PROJECT_DIR/hooks/404notfood/pre_tool_use_block_network/pre_tool_use_block_network.sh\""
          }
        ]
      }
    ]
  }
}
```

`$CLAUDE_PROJECT_DIR` est exposée nativement par Claude Code - aucun `.env` requis.

## Prérequis
- `jq` disponible dans le PATH

## Environnement testé
- Outil : Claude Code
- Shell : Git Bash (Windows / Laragon) et bash Linux
