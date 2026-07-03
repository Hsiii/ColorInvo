import type { JSX } from 'react';
import type { LucideIcon } from 'lucide-react';
import {
    ChevronRight,
    LifeBuoy,
    Palette,
    ShieldCheck,
    Smartphone,
} from 'lucide-react';
import Image from 'next/image';
import Link from 'next/link';

import { SiteShell } from './LegalPage';
import { ROUTES, SITE } from './site';

const panels: ReadonlyArray<{
    readonly body: string;
    readonly href: string;
    readonly icon: LucideIcon;
    readonly title: string;
}> = [
    {
        body: 'Get help adding the widget, saving your Taiwan mobile invoice carrier, or reporting a scanning issue.',
        href: ROUTES.support,
        icon: LifeBuoy,
        title: 'Support',
    },
    {
        body: 'ColorInvo keeps the carrier code, palette, and widget settings on device in the shared app group.',
        href: ROUTES.privacy,
        icon: ShieldCheck,
        title: 'Privacy',
    },
    {
        body: 'Pick a wallpaper image and ColorInvo builds scan-conscious barcode colors from it on device.',
        href: ROUTES.support,
        icon: Palette,
        title: 'Wallpaper palettes',
    },
];

export default function HomePage(): JSX.Element {
    return (
        <SiteShell active='home'>
            <section className='homeHero'>
                <div className='homeHero__copy'>
                    <p className='eyebrow'>{SITE.localName}</p>
                    <h1 className='homeHero__title'>{SITE.name}</h1>
                    <p className='homeHero__lede'>
                        Taiwan mobile invoice carrier barcode widgets that match
                        your wallpaper while keeping setup data local.
                    </p>
                    <div className='homeHero__actions'>
                        <Link className='actionLink' href={ROUTES.support}>
                            <LifeBuoy aria-hidden='true' size={20} />
                            Support
                        </Link>
                        <Link className='secondaryLink' href={ROUTES.privacy}>
                            <ShieldCheck aria-hidden='true' size={20} />
                            Privacy
                        </Link>
                    </div>
                </div>
                <aside
                    aria-label='ColorInvo app summary'
                    className='appPreview'
                >
                    <Image
                        alt='ColorInvo app icon'
                        className='appPreview__icon'
                        height={112}
                        priority
                        src='/colorinvo-icon.png'
                        width={112}
                    />
                    <div className='appPreview__text'>
                        <p className='appPreview__title'>
                            Home Screen carrier widget
                        </p>
                        <p>
                            Save the carrier once, choose a palette, and show
                            the barcode in an iOS widget.
                        </p>
                    </div>
                </aside>
            </section>
            <section aria-label='Site sections' className='homeSection'>
                <div className='panelGrid'>
                    {panels.map((panel) => {
                        const Icon = panel.icon;

                        return (
                            <Link
                                className='panel'
                                href={panel.href}
                                key={panel.title}
                            >
                                <span className='panel__icon'>
                                    <Icon aria-hidden='true' size={24} />
                                </span>
                                <p className='panel__title'>{panel.title}</p>
                                <p className='panel__body'>{panel.body}</p>
                                <span className='panel__footer'>
                                    Open
                                    <ChevronRight
                                        aria-hidden='true'
                                        size={20}
                                    />
                                </span>
                            </Link>
                        );
                    })}
                </div>
            </section>
            <section className='homeSection'>
                <div className='callout'>
                    <p className='callout__title'>
                        Built for the Taiwan mobile invoice carrier flow.
                    </p>
                    <p>
                        ColorInvo supports Code 39 carrier barcodes, validates
                        the saved value, and shares the same settings with the
                        widget through the iOS app group.
                    </p>
                    <Smartphone aria-hidden='true' size={24} />
                </div>
            </section>
        </SiteShell>
    );
}
