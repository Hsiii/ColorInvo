<div align="center">
  <img src="apps/ios/Resources/ColorInvo/Assets.xcassets/AppIcon.appiconset/AppIcon-10241024-1x.png" alt="條色盤 app icon" width="96" />
  <h1>條色盤</h1>
  <p>讓你的載具條碼在 iOS 與 Android 都能和桌布顏色完美搭配。</p>
  <a href="./README.md">English</a>
</div>

## 功能介紹

- **一秒出示載具：** 利用 iOS 或 Android 小工具輕鬆展示載具條碼。
- **桌布主題配色：** 選一張桌布圖片，自動抓代表色與小張預覽並產生配色方案。
- **保證能掃的到：** 確保條碼配色符合商業掃描器反射率對比規則。

## 在 Android 執行

先用 Android Studio 安裝 Android 16 / API 36 SDK，啟動模擬器或連接已解鎖的裝置，接著執行：

```sh
bun run android
```

執行單元測試、Lint，並編譯 App 與裝置測試 APK：

```sh
bun run android:check
```

連接裝置或模擬器後，可執行完整介面與小工具測試：

```sh
bun run android:test:device
```

## Google Play 發佈

1. 將 `apps/android/keystore.properties.example` 複製為 `apps/android/keystore.properties`，填入私密的 Play 上傳金鑰資訊。
2. 執行 `cd apps/android && bundle install` 安裝上傳工具。
3. 將 `PLAY_SERVICE_ACCOUNT_JSON` 指向具有發佈權限的 Play Console 服務帳戶金鑰。
4. 執行 `bun run android:bundle` 產生簽署的 AAB，或用 `bun run android:release` 完成檢查、打包並上傳至內部測試軌。

版本、測試軌與分階段發佈設定可放在 `.env.local`。商店文案位於 `apps/android/play`，隱私權政策為 [colorinvo.hsichen.dev/privacy](https://colorinvo.hsichen.dev/privacy)。連接 API 36 裝置後，可用 `bun run android:screenshots` 產生雙語商店截圖。

Play Console 初始設定、政策聲明、商店圖片與 CI 金鑰請參考 [完整發佈清單](apps/android/PLAY_RELEASE.md)。

## 在 iOS 模擬器執行

建置條色盤、啟動並開啟可用的 iPhone 模擬器，然後安裝與執行 App：

```sh
bun run simulator
```
