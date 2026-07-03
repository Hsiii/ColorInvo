import type { JSX } from 'react';
import Image from 'next/image';

import { SiteShell } from './LegalPage';
import { SITE } from './site';

const details: ReadonlyArray<{
    readonly body: string;
    readonly title: string;
}> = [
    {
        title: '手機條碼',
        body: '輸入一次載具號碼，App 會檢查格式並產生適合掃描的 Code 39 條碼。',
    },
    {
        title: '桌面小工具',
        body: '儲存後直接放到 iPhone 主畫面，需要結帳時不用再開發票 App。',
    },
    {
        title: '本機處理',
        body: '桌布取色與小工具設定都在裝置上完成，沒有帳號、廣告或後端服務。',
    },
];

export default function HomePage(): JSX.Element {
    return (
        <SiteShell>
            <section className='homeHero'>
                <div className='homeHero__copy'>
                    <h1 className='homeHero__title'>
                        {SITE.localName} {SITE.name}
                    </h1>
                    <p className='homeHero__lede'>
                        台灣手機條碼放進 iPhone 桌面小工具，配色跟著桌布走，
                        設定只留在裝置上。
                    </p>
                </div>
                <aside
                    aria-label={`${SITE.localName} App 畫面示意`}
                    className='demoPreview'
                >
                    <Image
                        alt={`${SITE.localName} App 顯示手機條碼與桌面小工具預覽`}
                        className='demoPreview__image'
                        height={2778}
                        priority
                        src='/colorinvo-demo.png'
                        width={1284}
                    />
                </aside>
            </section>
            <section aria-label='功能概要' className='homeSection homeDetails'>
                <ul className='homeDetails__list'>
                    {details.map((detail) => (
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
