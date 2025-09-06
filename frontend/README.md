# Frontend (Flutter)

This folder will contain the Flutter app for the 絵本生成アプリ frontend.

## Prerequisites
- Flutter SDK (stable)
- Xcode / Android Studio

## Create app

```bash
flutter create frontend_flutter
```

Then move your code into this folder or create it here.

## iOS 開発ガイド（FastAPI 連携）

- 前提:
  - Xcode と CocoaPods（`sudo gem install cocoapods`）
  - Flutter SDK（`brew install --cask flutter` など）
  - セットアップ確認: `flutter doctor`
- 依存追加:
  - `cd frontend_flutter`
  - `flutter pub add http`
- 開発用 API ベースURL（例）:
  - `http://127.0.0.1:8000/api/v1`（iOS シミュレータから Mac の FastAPI へ接続）
- Info.plist（HTTP 許可: 開発用）
  - 変更ファイル: `ios/Runner/Info.plist`
  - 次を追加（localhost/127.0.0.1 への HTTP を許可）:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSExceptionDomains</key>
  <dict>
    <key>localhost</key>
    <dict>
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <key>NSTemporaryExceptionMinimumTLSVersion</key>
      <string>TLSv1.0</string>
    </dict>
    <key>127.0.0.1</key>
    <dict>
      <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
      <true/>
      <key>NSTemporaryExceptionMinimumTLSVersion</key>
      <string>TLSv1.0</string>
    </dict>
  </dict>
</dict>
```

- 実行手順:
  1) バックエンド起動（別ターミナル）
     - `uvicorn app.main:app --reload --port 8000`（プロジェクトの `backend/` 内）
  2) iOS シミュレータ実行
     - `flutter run -d iOS`

- 署名・ビルドでエラーになる場合:
  - `open ios/Runner.xcworkspace` を開き、Signing & Capabilities で自分の Team を選択
  - CocoaPods 再構築: `cd ios && pod install --repo-update`
