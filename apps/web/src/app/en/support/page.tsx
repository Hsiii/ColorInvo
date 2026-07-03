import type { JSX } from 'react';
import type { Metadata } from 'next';

import { pageMetadata } from '../../i18n';
import { SupportPageContent } from '../../SupportPage';

export const metadata: Metadata = pageMetadata('en', 'support');

export default function EnglishSupportPage(): JSX.Element {
    return <SupportPageContent locale='en' />;
}
