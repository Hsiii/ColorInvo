import type { JSX } from 'react';
import Image from 'next/image';

import { getCopy } from './i18n';
import { SiteShell } from './LegalPage';
import type { Locale } from './site';

interface HomePageContentProps {
    readonly locale: Locale;
}

export function HomePageContent({ locale }: HomePageContentProps): JSX.Element {
    const copy = getCopy(locale);
    const page = copy.pages.home;

    return (
        <SiteShell currentPage='home' locale={locale}>
            <section className='homeHero'>
                <div className='homeHero__copy'>
                    <h1 className='homeHero__title'>{copy.brand}</h1>
                    <p className='homeHero__lede'>{page.lede}</p>
                </div>
                <aside aria-label={copy.demoLabel} className='demoPreview'>
                    <Image
                        alt={copy.demoAlt}
                        className='demoPreview__image'
                        height={2778}
                        priority
                        src='/colorinvo-demo.png'
                        width={1284}
                    />
                </aside>
            </section>
            <section
                aria-label={copy.detailsLabel}
                className='homeSection homeDetails'
            >
                <ul className='homeDetails__list'>
                    {page.details.map((detail) => (
                        <li className='homeDetails__item' key={detail.title}>
                            <h2 className='homeDetails__title'>
                                {detail.title}
                            </h2>
                            <p>{detail.body}</p>
                        </li>
                    ))}
                </ul>
            </section>
        </SiteShell>
    );
}
