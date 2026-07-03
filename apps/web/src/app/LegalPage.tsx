import type { JSX, ReactNode } from 'react';
import Image from 'next/image';
import Link from 'next/link';

import { ROUTES, SITE } from './site';

interface SiteShellProps {
    readonly children: ReactNode;
}

interface LegalPageProps {
    readonly children: ReactNode;
    readonly title: string;
}

const footerLinks = [
    { href: ROUTES.support, label: '支援 Support' },
    { href: ROUTES.privacy, label: '隱私 Privacy' },
] as const;

export function SiteShell({ children }: SiteShellProps): JSX.Element {
    return (
        <div className='siteShell'>
            <header className='siteHeader'>
                <nav aria-label='Primary' className='siteNav'>
                    <Link className='siteNav__brand' href={ROUTES.home}>
                        <Image
                            alt=''
                            aria-hidden='true'
                            className='siteNav__icon'
                            height={40}
                            priority
                            src='/colorinvo-icon.png'
                            width={40}
                        />
                        <span>{SITE.name}</span>
                    </Link>
                </nav>
            </header>
            <main className='siteMain'>{children}</main>
            <footer className='siteFooter'>
                <div className='siteFooter__inner'>
                    <p>
                        {SITE.localName} / {SITE.name}
                    </p>
                    <div className='siteFooter__links'>
                        {footerLinks.map((link) => (
                            <Link
                                className='legalLink'
                                href={link.href}
                                key={link.href}
                            >
                                {link.label}
                            </Link>
                        ))}
                    </div>
                </div>
            </footer>
        </div>
    );
}

export function LegalPage({ children, title }: LegalPageProps): JSX.Element {
    return (
        <SiteShell>
            <section className='legalHero'>
                <h1 className='legalHero__title'>{title}</h1>
            </section>
            <article className='legalContent'>{children}</article>
        </SiteShell>
    );
}
