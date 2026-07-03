import type { JSX, ReactNode } from 'react';
import Image from 'next/image';
import Link from 'next/link';

import { getCopy } from './i18n';
import type { Locale, SitePage } from './site';
import { routeFor } from './site';

interface SiteShellProps {
    readonly children: ReactNode;
    readonly currentPage: SitePage;
    readonly locale: Locale;
}

interface LegalPageProps {
    readonly children: ReactNode;
    readonly currentPage: Extract<SitePage, 'privacy' | 'support'>;
    readonly locale: Locale;
    readonly title: string;
}

const footerLinks = [
    'support',
    'privacy',
] as const satisfies readonly SitePage[];

export function SiteShell({
    children,
    currentPage,
    locale,
}: SiteShellProps): JSX.Element {
    const copy = getCopy(locale);

    return (
        <div className='siteShell' lang={copy.htmlLang}>
            <header className='siteHeader'>
                <nav aria-label={copy.shell.navLabel} className='siteNav'>
                    <Link
                        aria-current={
                            currentPage === 'home' ? 'page' : undefined
                        }
                        className='siteNav__brand'
                        href={routeFor(locale, 'home')}
                    >
                        <Image
                            alt=''
                            aria-hidden='true'
                            className='siteNav__icon'
                            height={40}
                            priority
                            src='/colorinvo-icon.png'
                            width={40}
                        />
                        <span>{copy.brand}</span>
                    </Link>
                </nav>
            </header>
            <main className='siteMain'>{children}</main>
            <footer className='siteFooter'>
                <div className='siteFooter__inner'>
                    <p>{copy.shell.footerBrand}</p>
                    <div className='siteFooter__links'>
                        {footerLinks.map((page) => (
                            <Link
                                className='legalLink'
                                href={routeFor(locale, page)}
                                key={page}
                            >
                                {copy.shell.footerLinks[page]}
                            </Link>
                        ))}
                    </div>
                </div>
            </footer>
        </div>
    );
}

export function LegalPage({
    children,
    currentPage,
    locale,
    title,
}: LegalPageProps): JSX.Element {
    return (
        <SiteShell currentPage={currentPage} locale={locale}>
            <section className='legalHero'>
                <h1 className='legalHero__title'>{title}</h1>
            </section>
            <article className='legalContent'>{children}</article>
        </SiteShell>
    );
}
