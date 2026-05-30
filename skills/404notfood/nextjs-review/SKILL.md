---
name: nextjs-review
description: "Utiliser ce skill pour relire du code Next.js (App Router, v16) : revue d'un diff, d'une PR, d'un Server/Client Component, d'une route handler, d'une Server Action, d'un layout/page, d'un fichier proxy ou de la config. Déclencher quand l'utilisateur demande une revue de code, un audit de sécurité ou de vérifier les conventions/perfs sur du Next.js (frontière server/client, fuite de secrets, async request APIs, data fetching, Cache Components, autorisation des Server Actions). Ne PAS déclencher pour du back-end non-Next, du CSS pur, ou la simple génération de code sans intention de revue."
---

# Next.js — Revue de code (App Router, v16)

Revue ciblée d'un diff ou d'un fichier Next.js utilisant l'App Router. Objectif : repérer les bugs réels, les failles de sécurité (surtout la frontière serveur/client) et les écarts de convention — pas réécrire le code.

## Démarche

1. Lire le diff (ou les fichiers indiqués). Sinon, prendre les changements non commités.
2. Vérifier la version (`package.json` → `next`) et si le projet est en App Router (`app/`) ou Pages Router (`pages/`) — ce skill cible l'App Router en v16. Calibrer les remarques selon la version exacte.
3. Classer chaque remarque : **Bloquant** / **À corriger** / **Suggestion**. Pointer fichier + ligne, donner le correctif.
4. Ne rien inventer : ce qui dépend de code non visible est signalé comme hypothèse.

## Spécificités Next.js 16 (à vérifier en priorité)

- **Async Request APIs (breaking)** : `params`, `searchParams`, `cookies()`, `headers()` sont **toujours asynchrones** en v16 — l'accès synchrone est supprimé. Tout accès non `await`é (ex. `params.id` au lieu de `const { id } = await params`) = bloquant.
- **Cache Components** : le caching est **opt-in** via la directive `use cache` (sur pages, composants, fonctions). `cacheLife` et `cacheTag` sont stables (plus de préfixe `unstable_`). `updateTag` (Server Actions only) pour le read-your-writes. Les flags `experimental.dynamicIO` / `experimental.useCache` sont dépréciés au profit de `cacheComponents` au niveau racine.
- **Proxy remplace Middleware** : le fichier `middleware.ts` est déprécié, renommé en `proxy.ts` (frontière réseau / routage). Signaler un nouveau `middleware.ts` dans un projet v16.
- **Turbopack** est le bundler par défaut. `next lint` est retiré (utiliser ESLint directement / Biome).

## Frontière Server / Client (priorité)

- **Server Components par défaut** : un fichier sans `"use client"` s'exécute sur le serveur. Vérifier que `"use client"` n'est ajouté que là où il y a interactivité/état/hooks navigateur — pas « par habitude » en haut de l'arbre (ça bascule tout le sous-arbre côté client).
- **Pattern îlots** : garder l'UI en Server Components, isoler l'interactivité dans de petits Client Components.
- **Hooks client dans un Server Component** (`useState`, `useEffect`, `onClick`…) sans `"use client"` = erreur → signaler.
- **`server-only`** : les modules touchant DB/secrets devraient importer `server-only` pour casser le build s'ils fuient côté client.

## Sécurité

- **Secrets exposés (bloquant)** : toute variable accédée dans un Client Component doit être préfixée `NEXT_PUBLIC_`. Inversement, un secret (`API_KEY`, token DB…) préfixé `NEXT_PUBLIC_` = fuite dans le bundle client → bloquant.
- **Server Actions** : traiter chaque `"use server"` comme un endpoint public. Vérifier l'**authentification ET l'autorisation** dans l'action elle-même (les restrictions d'UID côté UI ne suffisent pas). Valider les entrées (zod ou équivalent).
- **Route Handlers** (`app/**/route.ts`) : mêmes contrôles qu'une API publique (auth, validation, pas de données sensibles renvoyées sans filtrage).
- **Data Access Layer** : idéalement, l'accès aux données passe par une couche dédiée qui contrôle ce qui est renvoyé au render — pas de requête DB brute dispersée dans les composants.
- **Données sensibles passées en props** à un Client Component : vérifier qu'on ne sérialise pas vers le client des champs privés (penser aux React Taint APIs si le projet les utilise).

## Data fetching & caching (Next 16)

- **Caching opt-in** : par défaut le rendu est dynamique. Le caching s'active explicitement avec `use cache` (+ `cacheLife`/`cacheTag` pour le contrôle granulaire). Vérifier que les données réellement statiques sont cachées et que les données dynamiques/personnalisées ne le sont pas par erreur.
- **Suspense / streaming** : un `fetch` non caché bloque le rendu jusqu'à résolution → suggérer `<Suspense>` pour streamer.
- **Memoization** : des `fetch` identiques dans l'arbre sont dédupliqués — préférer fetcher dans le composant qui en a besoin plutôt que de faire du prop drilling.
- **Fetch côté client inutile** : si la donnée peut être récupérée côté serveur, éviter un `useEffect`+`fetch` client (waterfall, pas de cache, expose l'endpoint).
- **Invalidation après mutation** : `revalidatePath`/`revalidateTag` après une Server Action ; `updateTag` quand on veut un affichage immédiat (read-your-writes) dans la même requête.

## Conventions & qualité

- Fichiers spéciaux App Router corrects : `loading.tsx`, `error.tsx` (Client Component obligatoire), `not-found.tsx`, `layout.tsx`. Logique de frontière réseau dans `proxy.ts` (et non plus `middleware.ts` en v16).
- Pas de `console.log` / `debugger` oubliés dans le diff.
- TypeScript : pas de `any` injustifié ; typage des props et des réponses d'API.
- Images via `next/image` (pas `<img>` brut) pour le lazy-loading et le sizing.
- `async/await` dans les Server Components plutôt que des `.then()` imbriqués.

## Format de sortie

```
## Revue Next.js — <fichier ou PR>

### Bloquant
- [app/.../fichier.tsx:42] <problème> → <correctif>

### À corriger
- ...

### Suggestion
- ...

### OK
- <points déjà corrects>
```

Si aucun problème : le dire explicitement plutôt que d'inventer des remarques.
