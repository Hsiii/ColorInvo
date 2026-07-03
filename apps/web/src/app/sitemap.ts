import type { MetadataRoute } from 'next';

import { ROUTES, SITE } from './site';

export const dynamic = 'force-static';

const lastModified = new Date('2026-07-03');

type Sitemap = ReadonlyArray<MetadataRoute.Sitemap[number]>;

const sitemapEntries: Sitemap = [
    {
        url: `${SITE.url}${ROUTES.home}`,
        lastModified,
        changeFrequency: 'monthly',
        priority: 1,
    },
    {
        url: `${SITE.url}${ROUTES.support}`,
        lastModified,
        changeFrequency: 'monthly',
        priority: 0.8,
    },
    {
        url: `${SITE.url}${ROUTES.privacy}`,
        lastModified,
        changeFrequency: 'yearly',
        priority: 0.8,
    },
];

export default function sitemap(): Sitemap {
    return sitemapEntries;
}
