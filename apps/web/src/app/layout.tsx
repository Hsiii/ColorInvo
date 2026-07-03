import type { JSX, ReactNode } from 'react';
import type { Metadata } from 'next';

import { SITE } from './site';

import './global.css';

export const metadata: Metadata = {
    metadataBase: new URL(SITE.url),
    title: {
        default: `${SITE.name} - Taiwan carrier barcode widgets`,
        template: `%s | ${SITE.name}`,
    },
    description: SITE.description,
    alternates: {
        canonical: '/',
    },
    openGraph: {
        title: SITE.name,
        description: SITE.description,
        url: SITE.url,
        siteName: SITE.name,
        images: [
            {
                url: '/colorinvo-icon.png',
                width: 1024,
                height: 1024,
                alt: `${SITE.name} app icon`,
            },
        ],
    },
    icons: {
        icon: '/favicon.png',
        apple: '/apple-touch-icon.png',
    },
};

interface RootLayoutProps {
    readonly children: ReactNode;
}

export default function RootLayout({ children }: RootLayoutProps): JSX.Element {
    return (
        <html lang='en'>
            <body>{children}</body>
        </html>
    );
}
