import type { JSX } from 'react';
import { Bug, Smartphone, WandSparkles } from 'lucide-react';

import { getCopy } from './i18n';
import { LegalPage } from './LegalPage';
import type { Locale } from './site';
import { routeFor, SITE } from './site';

interface SupportPageContentProps {
    readonly locale: Locale;
}

const issueIcons = {
    bug: Bug,
    phone: Smartphone,
    sparkles: WandSparkles,
} as const;

export function SupportPageContent({
    locale,
}: SupportPageContentProps): JSX.Element {
    const copy = getCopy(locale);
    const page = copy.pages.support;
    const supportUrl = `${SITE.url}${routeFor(locale, 'support')}`;

    return (
        <LegalPage currentPage='support' locale={locale} title={page.title}>
            <section className='legalSection'>
                <h2 className='legalSection__title'>{page.contactTitle}</h2>
                <p>
                    {page.contactBody}{' '}
                    <a
                        className='legalLink'
                        href={`mailto:${SITE.supportEmail}?subject=ColorInvo%20Support`}
                    >
                        {SITE.supportEmail}
                    </a>
                    .
                </p>
                <p>{page.responseTime}</p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>{page.setupTitle}</h2>
                <ul>
                    {page.setupItems.map((item) => (
                        <li key={item}>{item}</li>
                    ))}
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>
                    {page.commonIssuesTitle}
                </h2>
                <ul className='supportList'>
                    {page.issues.map((issue) => {
                        const Icon = issueIcons[issue.icon];

                        return (
                            <li className='supportList__item' key={issue.title}>
                                <span className='supportList__icon'>
                                    <Icon aria-hidden='true' size={24} />
                                </span>
                                <div>
                                    <p className='supportList__title'>
                                        {issue.title}
                                    </p>
                                    <p className='supportList__body'>
                                        {issue.body}
                                    </p>
                                </div>
                            </li>
                        );
                    })}
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>{page.reportTitle}</h2>
                <p>{page.reportIntro}</p>
                <ul>
                    {page.reportItems.map((item) => (
                        <li key={item}>{item}</li>
                    ))}
                </ul>
                <p>
                    {page.supportUrlLabel}{' '}
                    <a className='legalLink' href={supportUrl}>
                        {supportUrl}
                    </a>
                </p>
            </section>
        </LegalPage>
    );
}
