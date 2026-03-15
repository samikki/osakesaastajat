import SwiftUI

// MARK: - Shared Styling

extension Color {
    /// Authentic VIC-20 blue background
    static let vic20Blue = Color(red: 0.0, green: 0.0, blue: 0.55)
}

extension Font {
    static let vic20 = Font.system(.body, design: .monospaced)
    static let vic20Small = Font.system(.footnote, design: .monospaced)
    static let vic20Large = Font.system(.title2, design: .monospaced).bold()
    static let vic20Title = Font.system(.title, design: .monospaced).bold()
}

// Retro button style
struct Vic20ButtonStyle: ButtonStyle {
    var color: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.vic20)
            .foregroundColor(.vic20Blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(configuration.isPressed ? color.opacity(0.7) : color)
            .cornerRadius(0)
            .overlay(
                Rectangle()
                    .stroke(color, lineWidth: 2)
            )
    }
}

// MARK: - Content View (Phase Router)

struct ContentView: View {
    @EnvironmentObject var game: GameModel

    var body: some View {
        ZStack {
            Color.vic20Blue.ignoresSafeArea()

            switch game.phase {
            case .title:
                TitleView()
            case .setup:
                SetupView()
            case .buying(let idx):
                BuyView(playerIndex: idx)
            case .selling(let idx):
                SellView(playerIndex: idx)
            case .dividends:
                DividendView()
            case .priceEvents(let events):
                PriceEventView(events: events)
            case .askQuit:
                AskQuitView()
            case .endGame:
                EndGameView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
