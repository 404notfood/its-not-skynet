# Meta — seo-nextjs

## Source
- Auteur : 404notfood
- Repo : https://github.com/Baylox/its-not-skynet
- Statut : **Créé par moi**

## Contexte d'usage
Skill SEO technique **on-page ciblé Next.js App Router (v16)** : sert aussi bien à **auditer** qu'à **implémenter**. Couvre la Metadata API (objet `metadata` statique et `generateMetadata` dynamique avec `params` async en v16), les images sociales conventionnelles (`opengraph-image`, `twitter-image`), les fichiers `sitemap.ts` et `robots.ts` (file-based, versionnés), canonical via `alternates`, hreflang via `alternates.languages`, données structurées JSON-LD, et les points de performance (next/image, Server Components pour un HTML crawlable). Fournit des extraits de code prêts à l'emploi.

**Aucune requête réseau ni crawl** — conforme au scope du repo. Hors périmètre (signalé comme tel) : recherche de mots-clés, backlinks, vérification d'indexation Google.

Point clé v16 : `metadata`/`generateMetadata` ne fonctionnent que dans des Server Components ; le skill signale tout export de métadonnées dans un fichier `"use client"`.

## Installation

### Pour un skill — Copier dans le projet cible :
```
.claude/skills/seo-nextjs.md
```

(copier le contenu de `SKILL.md` sous ce nom)

## Environnement testé
- Outil : Claude Code
- Stack : Next.js 16 (App Router), TypeScript
