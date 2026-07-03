import type { JSX } from 'react';
import type { Metadata } from 'next';

import { pageMetadata } from '../i18n';
import { PrivacyPageContent } from '../PrivacyPage';

export const metadata: Metadata = pageMetadata('zh', 'privacy');

export default function PrivacyPage(): JSX.Element {
    return <PrivacyPageContent locale='zh' />;
}
