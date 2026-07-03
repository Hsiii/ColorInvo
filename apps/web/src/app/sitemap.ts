import type { MetadataRoute } from 'next';

import { absoluteRoute, LOCALES } from './site';

export const dynamic = 'force-static';

const lastModified = new Date('2026-07-03');

type Sitemap = ReadonlyArray<MetadataRoute.Sitemap[number]>;

const pages = ['home', 'support', 'privacy'] as const;

const sitemapEntries: Sitemap = LOCALES.flatMap((locale) =>
    pages.map((page) => ({
        alternates: {
            languages: {
                'en': absoluteRoute('en', page),
                'x-default': absoluteRoute('zh', page),
                'zh-Hant-TW': absoluteRoute('zh', page),
            },
        },
        changeFrequency: page === 'privacy' ? 'yearly' : 'monthly',
        lastModified,
        priority: page === 'home' ? 1 : 0.8,
        url: absoluteRoute(locale, page),
    }))
);

export default function sitemap(): Sitemap {
    return sitemapEntries;
}
