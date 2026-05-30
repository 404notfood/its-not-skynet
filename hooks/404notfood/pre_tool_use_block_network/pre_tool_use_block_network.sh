#!/bin/bash
# Bloque les commandes qui declenchent un acces reseau non maitrise.
# Evenement : PreToolUse - matcher: "Bash"
# Exit 2 = blocage avec message dans stderr.
#
# Deterministe, aucune dependance reseau. Requiert : jq dans le PATH.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
    exit 0
fi

BLOCKED_REASON=""

if echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])(curl|wget|aria2c|http|https|ftp|lftp|nc|ncat|telnet)([[:space:]]|$)'; then
    BLOCKED_REASON="commande reseau directe"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])git[[:space:]]+(clone|fetch|pull|ls-remote)([[:space:]]|$)|(^|[;&|[:space:]])git[[:space:]]+submodule[[:space:]]+update([^;&|]*)[[:space:]]--init([[:space:]]|$)'; then
    BLOCKED_REASON="operation Git qui contacte un remote"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])npx([[:space:]]|$)|(^|[;&|[:space:]])npm[[:space:]]+(install|i|add|update|exec)([[:space:]]|$)'; then
    BLOCKED_REASON="commande npm/npx susceptible de telecharger ou executer un paquet distant"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])pnpm[[:space:]]+(install|i|add|update|dlx|exec)([[:space:]]|$)'; then
    BLOCKED_REASON="commande pnpm susceptible de telecharger ou executer un paquet distant"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])yarn[[:space:]]+(install|add|upgrade|dlx)([[:space:]]|$)'; then
    BLOCKED_REASON="commande yarn susceptible de telecharger ou executer un paquet distant"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])bun[[:space:]]+(install|add|update|x)([[:space:]]|$)'; then
    BLOCKED_REASON="commande bun susceptible de telecharger ou executer un paquet distant"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])(pip|pip3)[[:space:]]+(install|download)([[:space:]]|$)|(^|[;&|[:space:]])pipx[[:space:]]+(install|run)([[:space:]]|$)'; then
    BLOCKED_REASON="commande Python susceptible de telecharger ou executer un paquet distant"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])uv[[:space:]]+(add|sync|pip[[:space:]]+install|tool[[:space:]]+(install|run))([[:space:]]|$)'; then
    BLOCKED_REASON="commande uv susceptible de telecharger ou executer un paquet distant"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])composer[[:space:]]+(install|update|require|create-project)([[:space:]]|$)'; then
    BLOCKED_REASON="commande Composer susceptible de telecharger des dependances"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])cargo[[:space:]]+(install|update)([[:space:]]|$)|(^|[;&|[:space:]])go[[:space:]]+(get|install)([[:space:]]|$)'; then
    BLOCKED_REASON="commande de dependances susceptible de contacter un registre distant"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])docker[[:space:]]+(pull|run|buildx[[:space:]]+build)([[:space:]]|$)'; then
    BLOCKED_REASON="commande Docker susceptible de telecharger une image ou des dependances"
fi

if [[ -n "$BLOCKED_REASON" ]]; then
    echo "Bloque : acces reseau non maitrise detecte." >&2
    echo "Raison : $BLOCKED_REASON." >&2
    echo "Commande : $COMMAND" >&2
    echo "Si c'est intentionnel, execute la commande manuellement apres verification de la source." >&2
    exit 2
fi

exit 0
