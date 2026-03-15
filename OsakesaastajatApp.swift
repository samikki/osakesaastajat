import SwiftUI

@main
struct OsakesaastajatApp: App {
    @StateObject private var game = GameModel()
    @StateObject private var gameCenter = GameCenterManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(game)
                .environmentObject(gameCenter)
                .onAppear {
                    GameCenterManager.shared.authenticate()
                }
        }
    }
}
