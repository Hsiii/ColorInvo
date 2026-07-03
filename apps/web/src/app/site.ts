export const SITE = {
    name: 'ColorInvo',
    localName: '\u689D\u8272\u76E4',
    url: 'https://colorinvo.hsichen.dev',
    domain: 'colorinvo.hsichen.dev',
    supportEmail: 'its.hsichen@gmail.com',
    lastUpdated: 'July 3, 2026',
    description:
        'Wallpaper-matched Taiwan mobile invoice carrier barcode widgets for iPhone.',
} as const;

export const ROUTES = {
    home: '/',
    privacy: '/privacy',
    support: '/support',
} as const;

export type SiteRoute = keyof typeof ROUTES;
