import type { JSX } from 'react';
import type { Metadata } from 'next';

import { HomePageContent } from './HomePage';
import { pageMetadata } from './i18n';

export const metadata: Metadata = pageMetadata('zh', 'home');

export default function HomePage(): JSX.Element {
    return <HomePageContent locale='zh' />;
}
