import type { JSX, ReactNode } from 'react';
import type { Metadata } from 'next';

import { SITE } from './site';

import './global.css';

export const metadata: Metadata = {
    metadataBase: new URL(SITE.url),
    title: {
        default: `${SITE.localName} ${SITE.name} - 台灣手機條碼桌面小工具`,
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
                url: '/colorinvo-demo.png',
                width: 1284,
                height: 2778,
                alt: `${SITE.localName} App 畫面示意`,
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
        <html lang='zh-Hant-TW'>
            <body>{children}</body>
        </html>
    );
}
