import type { Metadata } from 'next';

import type { Locale, SitePage } from './site';
import { absoluteRoute, routeFor, SITE } from './site';

export const COPY = {
    en: {
        brand: SITE.name,
        demoAlt:
            'ColorInvo app screen showing carrier setup and widget preview',
        demoLabel: 'ColorInvo app screen demo',
        detailsLabel: 'Feature summary',
        htmlLang: 'en',
        lastUpdated: 'July 3, 2026',
        metadata: {
            home: {
                description:
                    'Taiwan mobile invoice carrier widgets for iPhone, with wallpaper-matched colors and on-device setup.',
                title: 'ColorInvo - Taiwan carrier widgets',
            },
            privacy: {
                description:
                    'ColorInvo privacy policy for local carrier settings, wallpaper color generation, widgets, and support contact.',
                title: 'Privacy Policy',
            },
            support: {
                description:
                    'Get help with ColorInvo carrier setup, widgets, color choices, and bug reports.',
                title: 'Support',
            },
        },
        ogLocale: 'en_US',
        pages: {
            home: {
                details: [
                    {
                        body: 'Save your carrier once. The app validates the format and creates a Code 39 barcode for checkout scanning.',
                        title: 'Carrier barcode',
                    },
                    {
                        body: 'Add the widget to your iPhone Home Screen so the barcode is ready without opening the invoice app.',
                        title: 'Home Screen widget',
                    },
                    {
                        body: 'Wallpaper color generation and widget settings stay on your device. No account, ads, or backend service.',
                        title: 'On-device setup',
                    },
                ],
                lede: 'Put your Taiwan mobile invoice carrier on the iPhone Home Screen, with colors that match your wallpaper and settings that stay on device.',
            },
            privacy: {
                sections: [
                    {
                        body: [
                            'ColorInvo stores your Taiwan mobile invoice carrier, barcode colors, and widget settings locally on your device. The app does not sell personal data, use third-party advertising, or require a ColorInvo account.',
                        ],
                        title: 'Summary',
                    },
                    {
                        items: [
                            'Carrier and color settings are stored in the iOS app group so the app and widget can read the same saved setup.',
                            'Wallpaper colors are generated on device from the image you select. ColorInvo saves the selected colors and a small local preview for the Home Screen preview.',
                            'If you email support, your email address and message content are used to respond to that request.',
                        ],
                        title: 'Stored information',
                    },
                    {
                        body: [
                            'ColorInvo only reads the image you choose through the Apple photo picker. The app does not browse your full photo library and does not upload selected images to a ColorInvo service. The preview image stays on your device.',
                        ],
                        title: 'Photos',
                    },
                    {
                        body: [
                            'The widget reads saved settings from the shared app group on the same device. ColorInvo does not share those settings with an external ColorInvo server.',
                            'Apple may process App Store downloads, purchases, diagnostics, crash reports, or TestFlight feedback under Apple policies and your settings.',
                        ],
                        title: 'Sharing',
                    },
                    {
                        body: [
                            'Local settings stay on the device until you change them, remove them in the app, or uninstall ColorInvo. Support emails are retained as needed to respond to and track the request.',
                        ],
                        title: 'Retention and control',
                    },
                    {
                        body: [
                            `This website is hosted at ${SITE.domain}. Hosting providers may process basic request information such as IP address, user agent, and timestamps to operate and secure the site.`,
                        ],
                        title: 'Website',
                    },
                ],
                contactBody: 'Questions about this policy can be sent to',
                contactTitle: 'Contact',
                lastUpdatedLabel: 'Last updated:',
                title: 'Privacy Policy',
            },
            support: {
                commonIssuesTitle: 'Common issues',
                contactBody:
                    'Need help? Email us. When reporting a bug, include the details below so the issue can be reproduced.',
                contactTitle: 'Contact',
                issues: [
                    {
                        body: 'Reopen ColorInvo, confirm that the carrier format is valid, save again, then wait for iOS to refresh the widget.',
                        icon: 'phone',
                        title: 'Widget does not show the barcode',
                    },
                    {
                        body: 'Choose a still image from Photos. The image is only used for local color generation and preview, and is not uploaded to ColorInvo.',
                        icon: 'sparkles',
                        title: 'Wallpaper colors cannot be generated',
                    },
                    {
                        body: 'Use a higher-contrast color choice and avoid red bars. Store scanners commonly use red light, so red bars can reduce readability.',
                        icon: 'bug',
                        title: 'Barcode scan fails at checkout',
                    },
                ],
                reportIntro: 'Please include:',
                reportItems: [
                    'Device model and iOS version.',
                    'ColorInvo version from the App Store or TestFlight.',
                    'A screenshot or screen recording when it helps explain the issue.',
                    'Steps to reproduce, including whether the issue is in the app or widget.',
                ],
                reportTitle: 'Bug reports',
                responseTime:
                    'Support is handled by the app developer. Most messages receive a reply within 1-3 business days.',
                setupItems: [
                    'Open ColorInvo and enter the 8-character carrier after the leading slash.',
                    'Choose barcode colors, or generate colors from a wallpaper photo on device.',
                    'Save, then add the ColorInvo widget from the iOS Home Screen widget picker.',
                ],
                setupTitle: 'Setup checklist',
                supportUrlLabel: 'Support URL:',
                title: 'Support',
            },
        },
        shell: {
            footerBrand: SITE.name,
            footerLinks: {
                privacy: 'Privacy',
                support: 'Support',
            },
            navLabel: 'Primary',
        },
    },
    zh: {
        brand: SITE.localName,
        demoAlt: '條色盤畫面顯示手機條碼設定與小工具預覽',
        demoLabel: '條色盤畫面示意',
        detailsLabel: '功能概要',
        htmlLang: 'zh-Hant-TW',
        lastUpdated: '2026 年 7 月 3 日',
        metadata: {
            home: {
                description:
                    '台灣手機條碼桌面小工具，配色跟著桌布走，設定只留在裝置上。',
                title: '條色盤 - 台灣手機條碼桌面小工具',
            },
            privacy: {
                description:
                    '條色盤隱私權政策：本機手機條碼設定、桌布取色、小工具與支援聯絡。',
                title: '隱私權政策',
            },
            support: {
                description:
                    '條色盤支援資訊：手機條碼設定、小工具、配色與錯誤回報。',
                title: '支援',
            },
        },
        ogLocale: 'zh_TW',
        pages: {
            home: {
                details: [
                    {
                        body: '輸入一次載具號碼，應用程式會檢查格式並產生適合掃描的條碼。',
                        title: '手機條碼',
                    },
                    {
                        body: '儲存後直接放到主畫面，需要結帳時不用再開發票應用程式。',
                        title: '桌面小工具',
                    },
                    {
                        body: '桌布取色與小工具設定都在裝置上完成，沒有帳號、廣告或後端服務。',
                        title: '本機處理',
                    },
                ],
                lede: '把台灣手機條碼放進桌面小工具，配色跟著桌布走，設定只留在裝置上。',
            },
            privacy: {
                sections: [
                    {
                        body: [
                            '條色盤會把台灣手機條碼、條碼配色與小工具設定儲存在你的裝置上。應用程式不販售個人資料、不使用第三方廣告，也不需要條色盤帳號。',
                        ],
                        title: '摘要',
                    },
                    {
                        items: [
                            '手機條碼與配色設定會儲存在系統的應用程式群組，讓應用程式與小工具讀取同一份設定。',
                            '桌布配色由你選擇的圖片在裝置上產生。條色盤會儲存選定的配色，以及用於主畫面預覽的小型本機預覽圖。',
                            '如果你寄信聯絡支援，寄件地址與信件內容會用於回覆該次請求。',
                        ],
                        title: '儲存的資訊',
                    },
                    {
                        body: [
                            '條色盤只會透過 Apple 照片選擇器讀取你選擇的圖片。應用程式不會瀏覽完整照片圖庫，也不會把選取圖片上傳到條色盤服務。預覽圖會留在你的裝置上。',
                        ],
                        title: '照片',
                    },
                    {
                        body: [
                            '小工具會從同一台裝置的共享應用程式群組讀取已儲存設定。條色盤不會把這些設定分享給外部伺服器。',
                            'Apple 可能依照 Apple 政策與使用者設定處理 App Store 下載、購買、診斷資料、當機報告或 TestFlight 回饋。',
                        ],
                        title: '分享',
                    },
                    {
                        body: [
                            '本機設定會留在裝置上，直到你變更設定、在應用程式中移除，或解除安裝條色盤。支援信件會視回覆與追蹤請求所需保留。',
                        ],
                        title: '保留與控制',
                    },
                    {
                        body: [
                            `本網站託管於 ${SITE.domain}。網站代管服務可能為了營運與保護網站，處理基本請求資訊，例如 IP 位址、使用者代理與時間戳記。`,
                        ],
                        title: '網站',
                    },
                ],
                contactBody: '對此政策有疑問，請寄信至',
                contactTitle: '聯絡方式',
                lastUpdatedLabel: '最後更新：',
                title: '隱私權政策',
            },
            support: {
                commonIssuesTitle: '常見問題',
                contactBody:
                    '需要協助請寄信給我們。回報問題時請附上下面資訊，方便確認與重現。',
                contactTitle: '聯絡方式',
                issues: [
                    {
                        body: '重新開啟條色盤，確認手機條碼格式正確並儲存，再稍等系統更新小工具內容。',
                        icon: 'phone',
                        title: '小工具沒有顯示條碼',
                    },
                    {
                        body: '請從照片選擇靜態圖片。圖片只用於本機取色與預覽，不會上傳到條色盤服務。',
                        icon: 'sparkles',
                        title: '無法從桌布產生配色',
                    },
                    {
                        body: '請改用對比更高的配色，並避免紅色條碼。商店掃描器常用紅光，紅色條碼會降低可讀性。',
                        icon: 'bug',
                        title: '結帳掃描失敗',
                    },
                ],
                reportIntro: '請包含：',
                reportItems: [
                    '裝置型號與系統版本。',
                    '商店或測試版本頁面上顯示的條色盤版本。',
                    '能說明問題的截圖或錄影。',
                    '重現步驟，並註明問題發生在應用程式或小工具。',
                ],
                reportTitle: '錯誤回報',
                responseTime:
                    '支援由應用程式開發者處理，多數訊息會在 1-3 個工作天內回覆。',
                setupItems: [
                    '開啟條色盤，輸入斜線後方 8 碼手機條碼載具。',
                    '選擇條碼配色，或從桌布照片在裝置上產生配色。',
                    '儲存後，到主畫面小工具選單加入條色盤。',
                ],
                setupTitle: '設定檢查',
                supportUrlLabel: '支援網址：',
                title: '支援',
            },
        },
        shell: {
            footerBrand: SITE.localName,
            footerLinks: {
                privacy: '隱私權',
                support: '支援',
            },
            navLabel: '主要導覽',
        },
    },
} as const;

export function getCopy(locale: Locale): (typeof COPY)[Locale] {
    return COPY[locale];
}

export function pageMetadata(locale: Locale, page: SitePage): Metadata {
    const copy = getCopy(locale);
    const pageCopy = copy.metadata[page];
    const otherLocale: Locale = locale === 'zh' ? 'en' : 'zh';

    return {
        alternates: {
            canonical: routeFor(locale, page),
            languages: {
                'en': routeFor('en', page),
                'x-default': routeFor('zh', page),
                'zh-Hant-TW': routeFor('zh', page),
            },
        },
        description: pageCopy.description,
        openGraph: {
            alternateLocale: [getCopy(otherLocale).ogLocale],
            description: pageCopy.description,
            images: [
                {
                    alt: copy.demoAlt,
                    height: 2778,
                    url: '/colorinvo-demo.png',
                    width: 1284,
                },
            ],
            locale: copy.ogLocale,
            siteName: copy.brand,
            title: pageCopy.title,
            url: absoluteRoute(locale, page),
        },
        title: pageCopy.title,
    };
}
