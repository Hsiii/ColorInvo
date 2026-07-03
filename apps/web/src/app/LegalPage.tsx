import type { JSX, ReactNode } from 'react';
import Image from 'next/image';
import Link from 'next/link';

import type { SiteRoute } from './site';
import { ROUTES, SITE } from './site';

interface SiteShellProps {
    readonly active: SiteRoute;
    readonly children: ReactNode;
}

interface LegalPageProps extends SiteShellProps {
    readonly eyebrow: string;
    readonly lede: string;
    readonly title: string;
}

const navLinks: ReadonlyArray<{
    readonly href: string;
    readonly id: SiteRoute;
    readonly label: string;
}> = [
    { href: ROUTES.support, id: 'support', label: 'Support' },
    { href: ROUTES.privacy, id: 'privacy', label: 'Privacy' },
];

export function SiteShell({ active, children }: SiteShellProps): JSX.Element {
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
                    <div className='siteNav__links'>
                        {navLinks.map((link) => (
                            <Link
                                aria-current={
                                    active === link.id ? 'page' : undefined
                                }
                                className='siteNav__link'
                                data-active={active === link.id}
                                href={link.href}
                                key={link.id}
                            >
                                {link.label}
                            </Link>
                        ))}
                    </div>
                </nav>
            </header>
            <main className='siteMain'>{children}</main>
            <footer className='siteFooter'>
                <div className='siteFooter__inner'>
                    <p>
                        {SITE.localName} / {SITE.name}
                    </p>
                    <div className='siteFooter__links'>
                        {navLinks.map((link) => (
                            <Link
                                className='legalLink'
                                href={link.href}
                                key={link.id}
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

export function LegalPage({
    eyebrow,
    lede,
    title,
    active,
    children,
}: LegalPageProps): JSX.Element {
    return (
        <SiteShell active={active}>
            <section className='legalHero'>
                <p className='eyebrow'>{eyebrow}</p>
                <h1 className='legalHero__title'>{title}</h1>
                <p className='legalHero__lede'>{lede}</p>
            </section>
            <article className='legalContent'>{children}</article>
        </SiteShell>
    );
}
