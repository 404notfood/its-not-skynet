---
name: seo-nextjs
description: "Utiliser ce skill pour faire le SEO technique on-page d'un projet Next.js App Router (v16) : auditer ET implémenter la Metadata API (objet metadata / generateMetadata), les images sociales (opengraph-image), sitemap.ts, robots.ts, canonical, hreflang et les données structurées JSON-LD. Déclencher quand l'utilisateur veut optimiser le SEO d'un site Next.js, ajouter des métadonnées par page, générer un sitemap/robots, ou mettre en place les bonnes pratiques SEO de l'App Router. Travaille uniquement sur les fichiers locaux du projet, sans requête réseau ni crawl. Ne PAS déclencher pour la recherche de mots-clés, l'analyse de backlinks ou la vérification d'indexation Google (hors scope, nécessite le réseau)."
---

# SEO Next.js (App Router v16, on-page, local)

Skill pour **auditer et implémenter** le SEO technique on-page d'un projet Next.js (App Router). Travaille uniquement sur les fichiers du dépôt (`app/`, fichiers de métadonnées, composants). **Aucune requête réseau, aucun crawl.**

Hors scope (réseau) : recherche de mots-clés, backlinks, indexation Google, mesure réelle de vitesse. Le signaler si demandé, sans le faire.

## Démarche

1. Repérer les `layout.tsx`/`page.tsx`, les fichiers de métadonnées (`app/sitemap.ts`, `app/robots.ts`, `opengraph-image.*`) et la config.
2. Décider : **audit** (manques classés Bloquant/À corriger/Suggestion + fichier:ligne) ou **implémentation** (proposer/écrire le code).
3. Ne rien inventer : `generateMetadata` et `metadata` ne fonctionnent que dans des **Server Components** — signaler tout export de métadonnées dans un fichier `"use client"`.

## 1. Metadata API (statique)

Exporter un objet `metadata` depuis un `layout.tsx` ou `page.tsx` (Server Component uniquement).

```tsx
// app/layout.tsx
import type { Metadata } from 'next'

export const metadata: Metadata = {
  metadataBase: new URL('https://exemple.com'),
  title: { default: 'Mon Site', template: '%s — Mon Site' },
  description: 'Description par défaut du site.',
  alternates: { canonical: '/' },
  openGraph: {
    title: 'Mon Site',
    description: 'Description par défaut du site.',
    url: 'https://exemple.com',
    siteName: 'Mon Site',
    type: 'website',
  },
  twitter: { card: 'summary_large_image' },
}
```

`title.template` évite de dupliquer le nom du site ; `metadataBase` rend les URLs OG/canonical absolues.

## 2. Métadonnées dynamiques (generateMetadata)

Pour les pages dépendant des params/données. En v16, **`params` est asynchrone** → l'`await`er.

```tsx
// app/articles/[slug]/page.tsx
import type { Metadata } from 'next'

export async function generateMetadata(
  { params }: { params: Promise<{ slug: string }> }
): Promise<Metadata> {
  const { slug } = await params
  const article = await getArticle(slug)
  return {
    title: article.title,
    description: article.excerpt,
    alternates: { canonical: `/articles/${slug}` },
    openGraph: { images: [article.coverUrl] },
  }
}
```

À vérifier : titre unique ~50–60 car., description ~120–160 car., canonical par page, pas de `generateMetadata` dans un Client Component, données réelles (pas de valeurs hardcodées).

## 3. Images sociales (opengraph-image)

Privilégier les fichiers conventionnels plutôt que des URLs en dur :
- `app/opengraph-image.{jpg,png}` (statique) ou `app/opengraph-image.tsx` (généré via `ImageResponse`).
- Idem `twitter-image.*`, `icon.*`, `apple-icon.*`, `favicon.ico`.

## 4. sitemap.ts & robots.ts (file-based, versionnés)

Pas de fichier physique : Next génère à partir de ces modules.

```ts
// app/sitemap.ts
import type { MetadataRoute } from 'next'

export default async function sitemap(): Promise<MetadataRoute.Sitemap> {
  const articles = await getPublishedArticles()
  return [
    { url: 'https://exemple.com', lastModified: new Date() },
    ...articles.map((a) => ({
      url: `https://exemple.com/articles/${a.slug}`,
      lastModified: a.updatedAt,
    })),
  ]
}
```

```ts
// app/robots.ts
import type { MetadataRoute } from 'next'

export default function robots(): MetadataRoute.Robots {
  return {
    rules: { userAgent: '*', allow: '/', disallow: '/admin/' },
    sitemap: 'https://exemple.com/sitemap.xml',
  }
}
```

Cohérence : une route en `noindex` ne doit pas figurer au sitemap ; `robots.ts` ne doit pas bloquer le site par erreur.

## 5. Données structurées (JSON-LD)

Injecter via un `<script>` dans un Server Component (jamais de données absentes hardcodées).

```tsx
export default function ArticlePage({ article }) {
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: article.title,
    datePublished: article.publishedAt,
  }
  return (
    <>
      <script type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      {/* ... */}
    </>
  )
}
```

## 6. Performance & i18n

- Images via `next/image` (lazy-loading, sizing, formats modernes automatiques).
- `hreflang` via `alternates.languages` dans la Metadata API pour un site multilingue.
- Éviter le rendu client inutile pour du contenu indexable (privilégier Server Components → HTML servi crawlable).

## Format de sortie (mode audit)

```
## SEO Next.js — <projet ou page>

### Bloquant
- [app/...:ligne] <problème> → <correctif>

### À corriger
- ...

### Suggestion
- ...

### OK
- <points déjà conformes>
```

En mode implémentation : proposer le code, indiquer le fichier cible, et ne modifier que si l'utilisateur le demande.
