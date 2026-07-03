import type { JSX } from 'react';
import type { Metadata } from 'next';

import { pageMetadata } from '../../i18n';
import { PrivacyPageContent } from '../../PrivacyPage';

export const metadata: Metadata = pageMetadata('en', 'privacy');

export default function EnglishPrivacyPage(): JSX.Element {
    return <PrivacyPageContent locale='en' />;
}
