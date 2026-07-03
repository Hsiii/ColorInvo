import type { JSX, ReactNode } from 'react';
import type { Metadata } from 'next';

import { SITE } from './site';

import './global.css';

export const metadata: Metadata = {
    metadataBase: new URL(SITE.url),
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
