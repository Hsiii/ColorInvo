import type { JSX } from 'react';
import { Bug, Mail, Smartphone, WandSparkles } from 'lucide-react';
import type { Metadata } from 'next';

import { LegalPage } from '../LegalPage';
import { SITE } from '../site';

export const metadata: Metadata = {
    title: 'Support',
    description:
        'Get help with ColorInvo carrier setup, wallpaper palettes, widgets, and bug reports.',
    alternates: {
        canonical: '/support',
    },
};

const setupItems = [
    'Open ColorInvo and enter the eight-character Taiwan mobile invoice carrier code after the leading slash.',
    'Choose a barcode color preset or pick a wallpaper image to generate palette options on device.',
    'Save, then add the ColorInvo widget from the iOS Home Screen widget picker.',
] as const;

const reportItems = [
    'Device model and iOS version.',
    'ColorInvo version from the App Store page or TestFlight build.',
    'A screenshot or screen recording when it helps explain the issue.',
    'Steps to reproduce, including whether the issue is in the app or widget.',
] as const;

export default function SupportPage(): JSX.Element {
    return (
        <LegalPage
            active='support'
            eyebrow='Support'
            lede='Help for carrier setup, wallpaper palettes, widget behavior, and scan-readiness issues.'
            title='ColorInvo Support'
        >
            <section className='legalSection'>
                <h2 className='legalSection__title'>Contact</h2>
                <p>
                    Email{' '}
                    <a
                        className='legalLink'
                        href={`mailto:${SITE.supportEmail}?subject=ColorInvo%20Support`}
                    >
                        {SITE.supportEmail}
                    </a>{' '}
                    for help. Include the details below when reporting a bug so
                    the issue can be reproduced quickly.
                </p>
                <div className='callout'>
                    <p className='callout__title'>Expected response time</p>
                    <p>
                        Support is handled by the app developer. Most messages
                        receive a reply within 1-3 business days.
                    </p>
                </div>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Setup Checklist</h2>
                <ul>
                    {setupItems.map((item) => (
                        <li key={item}>{item}</li>
                    ))}
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Common Issues</h2>
                <ul className='supportList'>
                    <li className='supportList__item'>
                        <span className='supportList__icon'>
                            <Smartphone aria-hidden='true' size={24} />
                        </span>
                        <div>
                            <p className='supportList__title'>
                                Widget does not show the barcode
                            </p>
                            <p className='supportList__body'>
                                Reopen ColorInvo, confirm the carrier code is
                                valid, tap save, then wait a moment for iOS to
                                refresh the widget timeline.
                            </p>
                        </div>
                    </li>
                    <li className='supportList__item'>
                        <span className='supportList__icon'>
                            <WandSparkles aria-hidden='true' size={24} />
                        </span>
                        <div>
                            <p className='supportList__title'>
                                Wallpaper palette cannot be generated
                            </p>
                            <p className='supportList__body'>
                                Choose a still image from Photos. The image is
                                loaded only for local palette generation and is
                                not uploaded by ColorInvo.
                            </p>
                        </div>
                    </li>
                    <li className='supportList__item'>
                        <span className='supportList__icon'>
                            <Bug aria-hidden='true' size={24} />
                        </span>
                        <div>
                            <p className='supportList__title'>
                                Barcode scan fails at checkout
                            </p>
                            <p className='supportList__body'>
                                Try a higher-contrast palette and avoid red bar
                                colors. Store scanners commonly use red light,
                                so red bars can reduce readability.
                            </p>
                        </div>
                    </li>
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Bug Reports</h2>
                <p>Please include:</p>
                <ul>
                    {reportItems.map((item) => (
                        <li key={item}>{item}</li>
                    ))}
                </ul>
                <p>
                    Support URL:{' '}
                    <a className='legalLink' href={`${SITE.url}/support`}>
                        {SITE.url}/support
                    </a>
                </p>
                <Mail aria-hidden='true' size={24} />
            </section>
        </LegalPage>
    );
}
