import type { JSX } from 'react';
import type { Metadata } from 'next';

import { HomePageContent } from '../HomePage';
import { pageMetadata } from '../i18n';

export const metadata: Metadata = pageMetadata('en', 'home');

export default function EnglishHomePage(): JSX.Element {
    return <HomePageContent locale='en' />;
}
