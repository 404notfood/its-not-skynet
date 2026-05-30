# Meta — nextjs_reviewer

## Source
- Auteur : 404notfood
- Repo : https://github.com/Baylox/its-not-skynet
- Statut : **Créé par moi**

## Contexte d'usage
Subagent de revue de code ciblé **Next.js App Router (v16)**. À déléguer avant un merge ou sur une PR : il relit (ne réécrit pas) et signale en priorité les breaking changes v16 (async request APIs `params`/`searchParams`/`cookies()`/`headers()`, `middleware.ts` → `proxy.ts`), les problèmes de frontière serveur/client (`"use client"` mal placé, hooks client dans un Server Component, `server-only`), les failles de sécurité (secrets exposés via `NEXT_PUBLIC_`, Server Actions sans auth/autorisation, Route Handlers non validés) et le data fetching / Cache Components (`use cache`, `<Suspense>`, `revalidateTag`/`updateTag`). Chaque remarque est classée par sévérité et pointe fichier + ligne avec un correctif.

Pendant « agent » du skill `nextjs-review` : même logique, mais en délégation de tâche isolée plutôt qu'en skill chargé dans le contexte.

## Installation

### Pour un subagent — Copier dans le projet cible :
```
.claude/agents/nextjs_reviewer.md
```

(copier le contenu de `nextjs_reviewer.md` sous ce nom ; le frontmatter `tools` limite l'agent à Read/Grep/Glob/Bash, donc lecture seule + commandes git de diff)

## Environnement testé
- Outil : Claude Code
- Stack : Next.js 16 (App Router), TypeScript
