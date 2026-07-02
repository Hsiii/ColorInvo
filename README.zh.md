<h1 align="center">條色盤</h1>
<div align="center">

  台灣手機載具條碼保存工具，支援安全掃描配色與 WidgetKit 預覽。

  <img src="Resources/ColorInvo/Assets.xcassets/AppIcon.appiconset/AppIcon-10241024-1x.png" alt="條色盤 app icon" width="96" />

  <a href="./README.md">English</a>
   ·
  <a href="#開發">開發</a>
   ·
  <a href="#發佈">發佈</a>
</div>

## 為什麼

- **載具優先：** 保存台灣手機載具號碼，讓條碼隨時可用。
- **支援小工具：** 在 App 內預覽條碼，再加入 iOS 小工具。
- **掃描安全配色：** 推薦與自訂配色會依掃描器取向的對比規則檢查。
- **桌布配色：** 從使用者選取的桌布圖片產生三組配色。
- **本機儲存：** 載具與配色存於 app group，供 App 與 Widget 共用。

## 需求

- 已安裝 Xcode 的 macOS
- iOS 17 SDK 或更新版本
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [Bun](https://bun.sh)
- 實機、Widget entitlement、封存或上傳流程需要 Apple Developer 帳號

## 第一次執行

安裝工具、產生 Xcode 專案，並執行模擬器建置檢查：

```bash
brew install xcodegen
make check
```

需要直接檢查或執行產生後的專案時，開啟 `ColorInvo.xcodeproj`。

## 開發

常用命令同時提供 `make` 與 `bun run` 入口：

| 工作 | Make | Bun |
| --- | --- | --- |
| 產生專案 | `make generate` | `bun run generate` |
| 完整本機檢查 | `make check` | `bun run check` |
| 模擬器建置 | `make simulator` | `bun run simulator` |
| 實機安裝並啟動 | `make device` | `bun run ios` |
| 清除建置產物 | `make clean` | - |

`check` 會重新產生 Xcode 專案、檢查本地化檔案、驗證 app group 設定，並執行模擬器建置。

## 實機建置

複製 `.env.example` 為 `.env` 或 `.env.local`，並設定 `APPLE_TEAM_ID`：

```bash
APPLE_TEAM_ID=XXXXXXXXXX
```

連接實機後建置、安裝並啟動：

```bash
make device
```

Apple Developer 帳號必須替 `dev.hsichen.colorinvo` 與 `dev.hsichen.colorinvo.widget` 啟用 `group.dev.hsichen.colorinvo`。

## 發佈

這個專案正在評估提交 App Store，因此封存、匯出與上傳流程會維持可重現，方便後續整理上架資訊與審查材料。

在 `.env` 或 `.env.local` 設定同一組 `APPLE_TEAM_ID`，並補上 App Store Connect API key：

```bash
ASC_KEY_ID=
ASC_ISSUER_ID=
ASC_KEY_PATH=
```

封存、匯出或上傳：

```bash
make archive
make export
make upload
```

互動式封存與上傳流程：

```bash
make release
```

## 隱私

條色盤會把載具號碼與配色存在 shared app group，讓 App 與 Widget 讀取同一份設定。桌布配色只會從使用者於裝置上選取的圖片產生。

## 疑難排解

如果專案產生失敗，確認 `xcodegen` 已安裝且在 `PATH` 中。如果實機簽署失敗，檢查 `APPLE_TEAM_ID`、bundle identifiers 與 Apple Developer portal 中的 app-group capabilities。如果上傳驗證失敗，請同時設定 `ASC_KEY_ID`、`ASC_ISSUER_ID` 與 `ASC_KEY_PATH`。
