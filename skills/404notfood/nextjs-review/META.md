# Meta — nextjs-review

## Source
- Auteur : 404notfood
- Repo : https://github.com/Baylox/its-not-skynet
- Statut : **Créé par moi**

## Contexte d'usage
Skill de revue de code ciblé **Next.js App Router (v16)**. S'utilise avant un merge ou sur une PR pour repérer en priorité : les **breaking changes v16** (async request APIs — `params`/`searchParams`/`cookies()`/`headers()` toujours `await`és ; `middleware.ts` → `proxy.ts`), les problèmes de **frontière serveur/client** (usage abusif de `"use client"`, hooks client dans un Server Component, `server-only`), les failles de sécurité (secrets exposés via `NEXT_PUBLIC_`, Server Actions sans auth/autorisation, Route Handlers non validés, données sensibles sérialisées vers le client), ainsi que le data fetching / **Cache Components** (`use cache`, `cacheLife`/`cacheTag`, `updateTag`, `<Suspense>`) et les conventions App Router. Le skill relit, il ne réécrit pas : chaque remarque est classée par sévérité et pointe fichier + ligne avec un correctif.

## Installation

### Pour un skill — Copier dans le projet cible :
```
.claude/skills/nextjs-review.md
```

(copier le contenu de `SKILL.md` sous ce nom)

## Environnement testé
- Outil : Claude Code
- Stack : Next.js 16 (App Router, Turbopack), TypeScript
