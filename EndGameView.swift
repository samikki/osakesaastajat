import SwiftUI

struct EndGameView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var gameCenter: GameCenterManager
    @State private var showLeaderboard = false
    @State private var scoreSubmitted = false

    private var totals: [Int] {
        [game.totalWealth(playerIndex: 0), game.totalWealth(playerIndex: 1)]
    }

    private var winner: String? { game.winnerName }
    private var isTie: Bool { winner == nil }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                Text("VAROJEN LASKENTA")
                    .font(.vic20Large)
                    .foregroundColor(.white)
                    .padding(.top, 24)

                // Player breakdown
                ForEach(0..<2, id: \.self) { t in
                    playerCard(playerIndex: t)
                }

                // Result
                resultBanner

                Divider().background(Color.white.opacity(0.2)).padding(.horizontal, 24)

                // Game Center
                if gameCenter.isAuthenticated {
                    VStack(spacing: 12) {
                        if !scoreSubmitted {
                            Text("Lähetetään tulos tulislistalle...")
                                .font(.vic20Small)
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            Text("✓ TULOS LÄHETETTY")
                                .font(.vic20Small)
                                .foregroundColor(.green)
                        }

                        Button("TULOSLISTAT") {
                            showLeaderboard = true
                        }
                        .buttonStyle(Vic20ButtonStyle(color: .yellow))
                    }
                }

                // Replay
                Button("UUSI PELI") {
                    game.resetToTitle()
                }
                .buttonStyle(Vic20ButtonStyle(color: .green))
                .padding(.bottom, 48)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
        .onAppear {
            submitScore()
        }
        .sheet(isPresented: $showLeaderboard) {
            GameCenterLeaderboardView(isPresented: $showLeaderboard)
        }
    }

    private func playerCard(playerIndex t: Int) -> some View {
        let player = game.players[t]
        let total = totals[t]
        let isWinner = winner == player.name

        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(player.name):N VARAT")
                    .font(.vic20)
                    .foregroundColor(.white)
                if isWinner {
                    Text("★ VOITTAJA")
                        .font(.vic20Small)
                        .foregroundColor(.yellow)
                }
            }

            // Cash
            HStack {
                Text("KÄTEINEN")
                    .font(.vic20Small)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text("\(player.capital) MK")
                    .font(.vic20Small)
                    .foregroundColor(.white)
            }

            // Stock holdings
            ForEach(game.companies) { company in
                let held = player.holdings[company.id]
                if held > 0 {
                    HStack {
                        Text(company.name)
                            .font(.vic20Small)
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(held) × \(company.price) =")
                            .font(.vic20Small)
                            .foregroundColor(.white.opacity(0.5))
                        Text("\(held * company.price) MK")
                            .font(.vic20Small)
                            .foregroundColor(.white)
                    }
                }
            }

            Divider().background(Color.white.opacity(0.3))

            HStack {
                Text("PAAOMA YHT")
                    .font(.vic20)
                    .foregroundColor(.white)
                Spacer()
                Text("\(total) MK")
                    .font(.vic20)
                    .foregroundColor(.yellow)
            }
        }
        .padding()
        .background(Color.white.opacity(isWinner ? 0.1 : 0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(isWinner ? Color.yellow : Color.white.opacity(0.15), lineWidth: isWinner ? 2 : 1)
        )
        .cornerRadius(4)
        .padding(.horizontal, 16)
    }

    private var resultBanner: some View {
        Group {
            if isTie {
                Text("REILU TASAPELI!")
                    .font(.vic20Large)
                    .foregroundColor(.white)
            } else {
                VStack(spacing: 8) {
                    Text("\(winner!) VOITTI!")
                        .font(.vic20Large)
                        .foregroundColor(.yellow)
                    Text("TULOS: \(game.winnerScore) MK")
                        .font(.vic20)
                        .foregroundColor(.white)
                }
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }

    private func submitScore() {
        guard !scoreSubmitted else { return }
        gameCenter.submitScore(game.winnerScore)
        scoreSubmitted = true
    }
}
