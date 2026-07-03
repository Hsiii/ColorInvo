import type { JSX } from 'react';
import type { Metadata } from 'next';

import { LegalPage } from '../LegalPage';
import { SITE } from '../site';

export const metadata: Metadata = {
    title: '隱私權政策',
    description:
        '條色盤隱私權政策：本機手機條碼設定、桌布取色、小工具與支援聯絡。',
    alternates: {
        canonical: '/privacy',
    },
};

export default function PrivacyPage(): JSX.Element {
    return (
        <LegalPage title='隱私權政策'>
            <section className='legalSection'>
                <h2 className='legalSection__title'>摘要</h2>
                <p>
                    ColorInvo
                    會把台灣手機條碼、條碼配色與小工具設定儲存在你的裝置上。 App
                    不販售個人資料、不使用第三方廣告，也不需要 ColorInvo 帳號。
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>儲存的資訊</h2>
                <ul>
                    <li>
                        手機條碼與配色設定會儲存在 iOS app group， 讓 App
                        與桌面小工具讀取同一份設定。
                    </li>
                    <li>
                        桌布配色由你選擇的圖片在裝置上產生。ColorInvo
                        會儲存選定的配色， 以及用於主畫面預覽的小型本機預覽圖。
                    </li>
                    <li>
                        如果你寄信聯絡支援，寄件地址與信件內容會用於回覆該次請求。
                    </li>
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>照片</h2>
                <p>
                    ColorInvo 只會透過 Apple 照片選擇器讀取你選擇的圖片。 App
                    不會瀏覽完整照片圖庫，也不會把選取圖片上傳到 ColorInvo
                    服務。 預覽圖會留在你的裝置上。
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>分享</h2>
                <p>
                    桌面小工具會從同一台裝置的 shared app group 讀取已儲存設定。
                    ColorInvo 不會把這些設定分享給外部 ColorInvo 伺服器。
                </p>
                <p>
                    Apple 可能依照 Apple 政策與使用者設定處理 App Store
                    下載、購買、 診斷資料、當機報告或 TestFlight 回饋。
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>保留與控制</h2>
                <p>
                    本機設定會留在裝置上，直到你變更設定、在 App
                    中移除，或解除安裝
                    ColorInvo。支援信件會視回覆與追蹤請求所需保留。
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>網站</h2>
                <p>
                    本網站託管於 {SITE.domain}
                    。網站代管服務可能為了營運與保護網站，
                    處理基本請求資訊，例如 IP 位址、使用者代理與時間戳記。
                </p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>聯絡方式</h2>
                <p>
                    對此政策有疑問，請寄信至{' '}
                    <a
                        className='legalLink'
                        href={`mailto:${SITE.supportEmail}?subject=ColorInvo%20Privacy`}
                    >
                        {SITE.supportEmail}
                    </a>
                    。
                </p>
                <p>最後更新：{SITE.lastUpdated}</p>
            </section>
        </LegalPage>
    );
}
