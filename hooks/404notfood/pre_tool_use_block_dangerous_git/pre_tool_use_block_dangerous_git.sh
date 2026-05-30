#!/bin/bash
# Bloque les commandes Git destructives ou de reecriture d'historique.
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

if echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])git[[:space:]]+reset([^;&|]*)[[:space:]]--hard([[:space:]]|$)'; then
    BLOCKED_REASON="git reset --hard supprime les changements locaux non commites"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])git[[:space:]]+clean([^;&|]*)[[:space:]]-[[:alnum:]-]*f[[:alnum:]-]*d[[:alnum:]-]*([[:space:]]|$)|(^|[;&|[:space:]])git[[:space:]]+clean([^;&|]*)[[:space:]]-[[:alnum:]-]*d[[:alnum:]-]*f[[:alnum:]-]*([[:space:]]|$)'; then
    BLOCKED_REASON="git clean -fd supprime les fichiers non suivis"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])git[[:space:]]+checkout([^;&|]*)[[:space:]]--[[:space:]]+([^;&|[:space:]]+|\.)([[:space:]]|$)'; then
    BLOCKED_REASON="git checkout -- <chemin> annule des modifications locales"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])git[[:space:]]+restore([^;&|]*)[[:space:]](\.|--worktree|--staged|[^-;&|[:space:]][^;&|[:space:]]*)([[:space:]]|$)'; then
    BLOCKED_REASON="git restore peut annuler des modifications locales"
elif echo "$COMMAND" | grep -qiE '(^|[;&|[:space:]])git[[:space:]]+push([^;&|]*)[[:space:]](-f|--force|--force-with-lease)([[:space:]]|$)'; then
    BLOCKED_REASON="git push --force reecrit l'historique distant"
fi

if [[ -n "$BLOCKED_REASON" ]]; then
    echo "Bloque : commande Git dangereuse detectee." >&2
    echo "Raison : $BLOCKED_REASON." >&2
    echo "Commande : $COMMAND" >&2
    echo "Si c'est intentionnel, execute la commande manuellement apres verification." >&2
    exit 2
fi

exit 0
