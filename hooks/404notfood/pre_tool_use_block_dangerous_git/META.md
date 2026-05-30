# Meta - pre_tool_use_block_dangerous_git

## Source
- Auteur : 404notfood
- Repo : https://github.com/Baylox/its-not-skynet
- Statut : **Cree par moi**

## Contexte d'usage
Empêche l'agent d'exécuter automatiquement des commandes Git qui peuvent supprimer du travail local ou réécrire l'historique distant :

- `git reset --hard`
- `git clean -fd` et variantes avec `-f` + `-d`
- `git checkout -- <chemin>`
- `git restore ...`
- `git push --force`, `git push -f`, `git push --force-with-lease`

Déterministe, pur shell, **aucun accès réseau**. Le hook ne fournit pas de bypass dans la commande elle-même : si l'action est réellement voulue, l'humain doit l'exécuter manuellement après vérification.

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
            "command": "bash \"$CLAUDE_PROJECT_DIR/hooks/404notfood/pre_tool_use_block_dangerous_git/pre_tool_use_block_dangerous_git.sh\""
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
