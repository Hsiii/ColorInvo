import type { JSX } from 'react';
import type { Metadata } from 'next';

import { LegalPage } from '../LegalPage';
import { SITE } from '../site';

export const metadata: Metadata = {
    title: 'Privacy Policy',
    description:
        'ColorInvo privacy policy for local carrier settings, wallpaper palette generation, widgets, and support contact.',
    alternates: {
        canonical: '/privacy',
    },
};

export default function PrivacyPage(): JSX.Element {
    return (
        <LegalPage
            active='privacy'
            eyebrow='Privacy Policy'
            lede='ColorInvo is designed to work without accounts, ads, analytics SDKs, or a ColorInvo backend.'
            title='Privacy Policy'
        >
            <section className='legalSection'>
                <h2 className='legalSection__title'>Summary</h2>
                <p>
                    ColorInvo stores the Taiwan mobile invoice carrier code,
                    selected barcode palette, and widget settings locally on
                    your device. The app does not sell personal data, does not
                    use third-party advertising, and does not require a
                    ColorInvo account.
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Information Stored</h2>
                <ul>
                    <li>
                        Carrier code and palette settings are stored in the iOS
                        app group so the app and widget can read the same saved
                        setup.
                    </li>
                    <li>
                        Wallpaper-derived palettes are generated on device from
                        the image you select. ColorInvo saves the derived color
                        choice, not the selected image.
                    </li>
                    <li>
                        If you email support, the email address and message
                        content you send are used to respond to the request.
                    </li>
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Photos</h2>
                <p>
                    ColorInvo uses Apple photo picker access only for the image
                    you choose. The app does not browse your full photo library
                    and does not upload selected images to a ColorInvo service.
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Sharing</h2>
                <p>
                    The widget reads the saved carrier settings from the shared
                    app group on the same device. ColorInvo does not share those
                    settings with an external ColorInvo server.
                </p>
                <p>
                    Apple may process App Store downloads, purchases,
                    diagnostics, crash reports, or TestFlight feedback under
                    Apple policies and user settings.
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Retention And Control</h2>
                <p>
                    Local settings remain on the device until you change them,
                    remove them through the app, or uninstall ColorInvo. Support
                    emails are retained as needed to respond to and track the
                    support request.
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Website</h2>
                <p>
                    This website is hosted at {SITE.domain}. Hosting providers
                    may process basic request information such as IP address,
                    user agent, and timestamps to operate and secure the site.
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>Contact</h2>
                <p>
                    Questions about this policy can be sent to{' '}
                    <a
                        className='legalLink'
                        href={`mailto:${SITE.supportEmail}?subject=ColorInvo%20Privacy`}
                    >
                        {SITE.supportEmail}
                    </a>
                    .
                </p>
                <p>Last updated: {SITE.lastUpdated}</p>
            </section>
        </LegalPage>
    );
}
