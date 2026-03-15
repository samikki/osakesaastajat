import SwiftUI

struct TitleView: View {
    @EnvironmentObject var game: GameModel
    @EnvironmentObject var gameCenter: GameCenterManager
    @State private var showLeaderboard = false

    // Retro blink animation
    @State private var blink = true
    private let timer = Timer.publish(every: 0.6, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // VIC-20 box art replica
            VStack(spacing: 0) {
                Text("┌────────────────────┐")
                Text("│                    │")
                Text("│  *OSAKESAASTAJAT*  │").bold()
                Text("│                    │")
                Text("├────────────────────┤")
                Text("│  ══════════════    │")
                Text("│  (C)SAMI.K 1984    │")
                Text("│                    │")
                Text("└────────────────────┘")
            }
            .font(.system(.body, design: .monospaced))
            .foregroundColor(.white)

            Spacer()

            // Blinking prompt
            Text(blink ? "PAINA NAPPIA." : "             ")
                .font(.system(.body, design: .monospaced))
                .foregroundColor(.white)
                .onReceive(timer) { _ in blink.toggle() }
                .padding(.bottom, 8)

            // Round info
            Text("MIKROBITTI 3/1985")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))
                .padding(.bottom, 32)

            // Buttons
            VStack(spacing: 12) {
                Button("UUSI PELI") {
                    game.phase = .setup
                }
                .buttonStyle(Vic20ButtonStyle())

                if gameCenter.isAuthenticated {
                    Button("TULOSLISTAT") {
                        showLeaderboard = true
                    }
                    .buttonStyle(Vic20ButtonStyle(color: .yellow))
                }
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
        .sheet(isPresented: $showLeaderboard) {
            GameCenterLeaderboardView(isPresented: $showLeaderboard)
        }
    }
}
