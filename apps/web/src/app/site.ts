export const SITE = {
    name: 'ColorInvo',
    localName: '條色盤',
    url: 'https://colorinvo.hsichen.dev',
    domain: 'colorinvo.hsichen.dev',
    supportEmail: 'its.hsichen@gmail.com',
} as const;

export const ROUTES = {
    en: {
        home: '/en',
        privacy: '/en/privacy',
        support: '/en/support',
    },
    zh: {
        home: '/',
        privacy: '/privacy',
        support: '/support',
    },
} as const;

export type Locale = keyof typeof ROUTES;
export type SitePage = keyof (typeof ROUTES)['zh'];

export const DEFAULT_LOCALE: Locale = 'zh';

export const LOCALES = ['zh', 'en'] as const satisfies readonly Locale[];

export function routeFor(locale: Locale, page: SitePage): string {
    return ROUTES[locale][page];
}

export function absoluteRoute(locale: Locale, page: SitePage): string {
    return `${SITE.url}${routeFor(locale, page)}`;
}
