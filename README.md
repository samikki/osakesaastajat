# Osakesaastajat — iOS App

Port of the classic 1984 Commodore VIC-20 Finnish stock market game, originally published in **Mikrobitti 3/1985**.

## Files

| File | Purpose |
|------|---------|
| `GameModel.swift` | All game state and logic (ObservableObject) |
| `GameCenterManager.swift` | GameKit / Game Center wrapper + leaderboard view |
| `OsakesaastajatApp.swift` | App entry point, triggers Game Center auth |
| `ContentView.swift` | Phase router + shared VIC-20 styling tokens |
| `TitleView.swift` | Title screen with retro box art |
| `SetupView.swift` | Multi-step form: 2 player names + 12 company names |
| `BuyView.swift` | Stock market table + buy sheet |
| `SellView.swift` | Portfolio view + sell sheet |
| `DividendView.swift` | Dividend display (paid on JATKA tap) |
| `PriceEventView.swift` | Stock split / bankruptcy events |
| `AskQuitView.swift` | LOPETAMMEKO? prompt |
| `EndGameView.swift` | Final scores + Game Center submission |

## Xcode Setup

### 1. Create Project

1. Open Xcode → **File → New → Project**
2. Choose **iOS → App**
3. Set:
   - Product Name: `Osakesaastajat`
   - Bundle Identifier: `com.yourname.osakesaastajat`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **iOS 16.0**

### 2. Add Source Files

Delete the generated `ContentView.swift` and drag all `.swift` files from this folder into the Xcode project navigator.

### 3. Enable Game Center

1. In Xcode, select your project target → **Signing & Capabilities**
2. Click **+ Capability** → add **Game Center**
3. In **App Store Connect** → your app → **Features → Leaderboards**:
   - Create a leaderboard with ID: `com.osakesaastajat.highscore`
   - Score format: Integer (Finnish Marks)
   - Sort: High to Low

### 4. Info.plist

Add a usage description for Game Center authentication if prompted.

### 5. Run

Build & run on a device or simulator. Game Center auth requires a real device with an Apple ID signed in.

---

## Game Rules (original)

- **2 players**, pass-and-play on one device
- Each player starts with **1200 MK**
- **12 companies**, prices start at **100 MK**
- Each round: Player 1 buys → Player 1 sells → Player 2 buys → Player 2 sells → Dividends → Ask quit
- **Dividends**: `shares × (price ÷ 10)` MK per company per round
- **Price changes**: random `−30` to `+30` MK each round
- **Osakeanti** (stock split): if price ≥ 200 → shares × 2, price reset to 100
- **Konkurssi** (bankruptcy): if price ≤ 0 → shares lost, price reset to 100
- **End game**: highest total wealth (cash + stock value) wins
- **High score**: winner's total MK submitted to Game Center leaderboard

---

*Alkuperäinen: Sami K., 1984 — iOS-versio: 2026*
