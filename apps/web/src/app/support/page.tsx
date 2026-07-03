import type { JSX } from 'react';
import type { Metadata } from 'next';

import { pageMetadata } from '../i18n';
import { SupportPageContent } from '../SupportPage';

export const metadata: Metadata = pageMetadata('zh', 'support');

export default function SupportPage(): JSX.Element {
    return <SupportPageContent locale='zh' />;
}
