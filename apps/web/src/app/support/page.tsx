import type { JSX } from 'react';
import { Bug, Smartphone, WandSparkles } from 'lucide-react';
import type { Metadata } from 'next';

import { LegalPage } from '../LegalPage';
import { SITE } from '../site';

export const metadata: Metadata = {
    title: '支援',
    description: '條色盤支援資訊：手機條碼設定、桌面小工具、配色與錯誤回報。',
    alternates: {
        canonical: '/support',
    },
};

const setupItems = [
    '開啟條色盤，輸入斜線後方 8 碼手機條碼載具。',
    '選擇條碼配色，或從桌布照片在裝置上產生配色。',
    '儲存後，到 iOS 主畫面小工具選單加入 ColorInvo。',
] as const;

const reportItems = [
    '裝置型號與 iOS 版本。',
    'App Store 或 TestFlight 上顯示的 ColorInvo 版本。',
    '能說明問題的截圖或錄影。',
    '重現步驟，並註明問題發生在 App 或桌面小工具。',
] as const;

export default function SupportPage(): JSX.Element {
    return (
        <LegalPage title='支援'>
            <section className='legalSection'>
                <h2 className='legalSection__title'>聯絡方式</h2>
                <p>
                    需要協助請寄信到{' '}
                    <a
                        className='legalLink'
                        href={`mailto:${SITE.supportEmail}?subject=ColorInvo%20Support`}
                    >
                        {SITE.supportEmail}
                    </a>
                    。回報問題時請附上下面資訊，方便確認與重現。
                </p>
                <p>支援由 App 開發者處理，多數訊息會在 1-3 個工作天內回覆。</p>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>設定檢查</h2>
                <ul>
                    {setupItems.map((item) => (
                        <li key={item}>{item}</li>
                    ))}
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>常見問題</h2>
                <ul className='supportList'>
                    <li className='supportList__item'>
                        <span className='supportList__icon'>
                            <Smartphone aria-hidden='true' size={24} />
                        </span>
                        <div>
                            <p className='supportList__title'>
                                小工具沒有顯示條碼
                            </p>
                            <p className='supportList__body'>
                                重新開啟 ColorInvo，確認手機條碼格式正確並儲存，
                                再稍等 iOS 更新小工具內容。
                            </p>
                        </div>
                    </li>
                    <li className='supportList__item'>
                        <span className='supportList__icon'>
                            <WandSparkles aria-hidden='true' size={24} />
                        </span>
                        <div>
                            <p className='supportList__title'>
                                無法從桌布產生配色
                            </p>
                            <p className='supportList__body'>
                                請從照片選擇靜態圖片。圖片只用於本機取色與預覽，
                                不會上傳到 ColorInvo 服務。
                            </p>
                        </div>
                    </li>
                    <li className='supportList__item'>
                        <span className='supportList__icon'>
                            <Bug aria-hidden='true' size={24} />
                        </span>
                        <div>
                            <p className='supportList__title'>結帳掃描失敗</p>
                            <p className='supportList__body'>
                                請改用對比更高的配色，並避免紅色條碼。商店掃描器常用紅光，
                                紅色條碼會降低可讀性。
                            </p>
                        </div>
                    </li>
                </ul>
            </section>
            <section className='legalSection'>
                <h2 className='legalSection__title'>錯誤回報</h2>
                <p>請包含：</p>
                <ul>
                    {reportItems.map((item) => (
                        <li key={item}>{item}</li>
                    ))}
                </ul>
                <p>
                    支援網址：{' '}
                    <a className='legalLink' href={`${SITE.url}/support`}>
                        {SITE.url}/support
                    </a>
                </p>
            </section>
        </LegalPage>
    );
}
