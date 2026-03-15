import SwiftUI

struct DividendView: View {
    @EnvironmentObject var game: GameModel

    // Pre-compute dividends for display (game.payDividends() is called on continue)
    private struct DividendEntry: Identifiable {
        let id = UUID()
        let playerName: String
        let companyName: String
        let amount: Int
    }

    private var entries: [DividendEntry] {
        var result: [DividendEntry] = []
        for t in 0..<2 {
            for i in 0..<12 {
                let shares = game.players[t].holdings[i]
                if shares > 0 {
                    let div = shares * (game.companies[i].price / 10)
                    if div > 0 {
                        result.append(DividendEntry(
                            playerName: game.players[t].name,
                            companyName: game.companies[i].name,
                            amount: div
                        ))
                    }
                }
            }
        }
        return result
    }

    private var totalByPlayer: [String: Int] {
        Dictionary(grouping: entries, by: \.playerName)
            .mapValues { $0.reduce(0) { $0 + $1.amount } }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("OSINGOT")
                .font(.vic20Large)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.black.opacity(0.3))

            if entries.isEmpty {
                Spacer()
                Text("EI OSINKOJA TÄLLÄ KIERROKSELLA.")
                    .font(.vic20)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(0..<2, id: \.self) { t in
                            let player = game.players[t]
                            let playerDivs = entries.filter { $0.playerName == player.name }

                            if !playerDivs.isEmpty {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("\(player.name):LLE:")
                                        .font(.vic20)
                                        .foregroundColor(.white)

                                    ForEach(playerDivs) { entry in
                                        HStack {
                                            Text(entry.companyName
                                                .padding(toLength: 10, withPad: "-", startingAt: 0))
                                                .font(.vic20Small)
                                                .foregroundColor(.white.opacity(0.8))
                                            Spacer()
                                            Text("\(entry.amount) MK")
                                                .font(.vic20Small)
                                                .foregroundColor(.yellow)
                                        }
                                    }

                                    HStack {
                                        Text("YHT:")
                                            .font(.vic20Small)
                                            .foregroundColor(.white.opacity(0.6))
                                        Spacer()
                                        Text("\(totalByPlayer[player.name] ?? 0) MK")
                                            .font(.vic20)
                                            .foregroundColor(.green)
                                    }
                                    .padding(.top, 4)
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(4)
                            }
                        }
                    }
                    .padding()
                }
            }

            // Continue button — actually pays dividends when tapped
            Button("JATKA") {
                game.payDividends()
            }
            .buttonStyle(Vic20ButtonStyle())
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity)
            .background(Color.black.opacity(0.3))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
    }
}
