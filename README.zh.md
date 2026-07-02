<h1 align="center">條色盤</h1>
<div align="center">

  收好手機載具條碼，搭配好掃又好看的配色，還能先預覽 iOS 小工具。

  <img src="Resources/ColorInvo/Assets.xcassets/AppIcon.appiconset/AppIcon-10241024-1x.png" alt="條色盤 app icon" width="96" />

  <a href="./README.md">English</a>
   ·
  <a href="#開發">開發</a>
   ·
  <a href="#發佈">發佈</a>
</div>

## 為什麼做

- **載具好找：** 把手機載具存起來，要刷條碼時不用再翻 App。
- **小工具先看：** 加入 iOS 小工具前，先在 App 裡確認條碼顯示。
- **配色不只好看：** 推薦與自訂色會依掃描器對比規則檢查，降低掃不到的機率。
- **跟桌布搭得起來：** 選一張桌布圖片，自動抓主色並產生三組搭配。
- **資料留在本機：** 載具與配色寫進 app group，App 和 Widget 共用同一份設定。

## 需求

- 裝好 Xcode 的 macOS
- iOS 17 SDK 或更新版本
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [Bun](https://bun.sh)
- 要跑實機、App Group / Widget 權限、封存或上傳流程，需要 Apple Developer 帳號

## 第一次執行

先裝好工具、產生 Xcode 專案，並跑一次模擬器建置檢查：

```bash
brew install xcodegen
make check
```

需要直接在 Xcode 裡檢查或執行專案時，開啟 `ColorInvo.xcodeproj`。

## 開發

常用指令可以走 `make`，也可以直接用 `bun run`：

| 任務 | Make | Bun |
| --- | --- | --- |
| 產生專案 | `make generate` | `bun run generate` |
| 完整本機檢查 | `make check` | `bun run check` |
| 模擬器建置 | `make simulator` | `bun run simulator` |
| 實機安裝並啟動 | `make device` | `bun run ios` |
| 清掉建置產物 | `make clean` | - |

`make check` 會重新產生 Xcode 專案、檢查本地化字串、確認 app group 設定，並跑一次模擬器建置。

## 實機建置

把 `.env.example` 複製成 `.env` 或 `.env.local`，並填入 `APPLE_TEAM_ID`：

```bash
APPLE_TEAM_ID=XXXXXXXXXX
```

接上 iPhone 後建置、安裝並啟動：

```bash
make device
```

Apple Developer 帳號裡要替 `dev.hsichen.colorinvo` 和 `dev.hsichen.colorinvo.widget` 啟用 `group.dev.hsichen.colorinvo`。

## 發佈

這個專案正在評估送 App Store，因此封存、匯出與上傳流程都會維持可重現，方便後續整理上架資訊與審查資料。

在 `.env` 或 `.env.local` 使用同一組 `APPLE_TEAM_ID`，並補上 App Store Connect API key：

```bash
ASC_KEY_ID=
ASC_ISSUER_ID=
ASC_KEY_PATH=
```

需要封存、匯出或上傳時：

```bash
make archive
make export
make upload
```

如果要走互動式封存與上傳流程：

```bash
make release
```

## 隱私

條色盤會把載具號碼與配色存在 shared app group，讓 App 和 Widget 讀同一份設定。桌布配色只會使用你在裝置上選取的圖片來產生。

## 疑難排解

如果專案產生失敗，先確認 `xcodegen` 已安裝且在 `PATH` 裡。如果實機簽署失敗，檢查 `APPLE_TEAM_ID`、bundle identifiers，以及 Apple Developer portal 裡的 app group capabilities。如果上傳驗證失敗，請同時設定 `ASC_KEY_ID`、`ASC_ISSUER_ID` 和 `ASC_KEY_PATH`。
