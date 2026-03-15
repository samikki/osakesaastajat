import SwiftUI

/// LOPETAMMEKO? [K/E]  — shown after dividends each round.
struct AskQuitView: View {
    @EnvironmentObject var game: GameModel

    private var w0: Int { game.totalWealth(playerIndex: 0) }
    private var w1: Int { game.totalWealth(playerIndex: 1) }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("LOPETAMMEKO?")
                .font(.vic20Title)
                .foregroundColor(.white)

            // Quick score preview
            VStack(spacing: 8) {
                Text("KIERROS \(game.round)")
                    .font(.vic20Small)
                    .foregroundColor(.white.opacity(0.5))

                Divider().background(Color.white.opacity(0.2))

                scoreRow(name: game.players[0].name, wealth: w0)
                scoreRow(name: game.players[1].name, wealth: w1)
            }
            .padding()
            .background(Color.white.opacity(0.05))
            .cornerRadius(4)
            .padding(.horizontal, 32)

            Spacer()

            HStack(spacing: 24) {
                Button("JATKA PELAAMISTA") {
                    game.startNewRound()
                }
                .buttonStyle(Vic20ButtonStyle(color: .green))

                Button("LOPETA") {
                    game.triggerEndGame()
                }
                .buttonStyle(Vic20ButtonStyle(color: .red))
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
    }

    private func scoreRow(name: String, wealth: Int) -> some View {
        HStack {
            Text("\(name):N VARAT")
                .font(.vic20Small)
                .foregroundColor(.white)
            Spacer()
            Text("\(wealth) MK")
                .font(.vic20Small)
                .foregroundColor(.yellow)
        }
    }
}
