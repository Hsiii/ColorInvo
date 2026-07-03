import type { JSX } from 'react';

import { getCopy } from './i18n';
import { LegalPage } from './LegalPage';
import type { Locale } from './site';
import { SITE } from './site';

interface PrivacyPageContentProps {
    readonly locale: Locale;
}

export function PrivacyPageContent({
    locale,
}: PrivacyPageContentProps): JSX.Element {
    const copy = getCopy(locale);
    const page = copy.pages.privacy;

    return (
        <LegalPage currentPage='privacy' locale={locale} title={page.title}>
            {page.sections.map((section) => (
                <section className='legalSection' key={section.title}>
                    <h2 className='legalSection__title'>{section.title}</h2>
                    {'body' in section
                        ? section.body.map((paragraph) => (
                              <p key={paragraph}>{paragraph}</p>
                          ))
                        : undefined}
                    {'items' in section ? (
                        <ul>
                            {section.items.map((item) => (
                                <li key={item}>{item}</li>
                            ))}
                        </ul>
                    ) : undefined}
                </section>
            ))}
            <section className='legalSection'>
                <h2 className='legalSection__title'>{page.contactTitle}</h2>
                <p>
                    {page.contactBody}{' '}
                    <a
                        className='legalLink'
                        href={`mailto:${SITE.supportEmail}?subject=ColorInvo%20Privacy`}
                    >
                        {SITE.supportEmail}
                    </a>
                    .
                </p>
                <p>
                    {page.lastUpdatedLabel} {copy.lastUpdated}
                </p>
            </section>
        </LegalPage>
    );
}
