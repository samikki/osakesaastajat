import GameKit
import SwiftUI

// MARK: - Game Center Manager

class GameCenterManager: NSObject, ObservableObject {
    static let shared = GameCenterManager()

    /// Leaderboard ID — must match what you create in App Store Connect
    static let leaderboardID = "com.osakesaastajat.highscore"

    @Published var isAuthenticated = false
    @Published var showLeaderboard = false

    private override init() { super.init() }

    // MARK: - Authentication

    func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            DispatchQueue.main.async {
                if GKLocalPlayer.local.isAuthenticated {
                    self?.isAuthenticated = true
                } else {
                    self?.isAuthenticated = false
                    if let error { print("GameCenter auth error: \(error.localizedDescription)") }
                }
            }
        }
    }

    // MARK: - Submit Score

    /// Submit winner's final wealth in Finnish Marks to the leaderboard.
    func submitScore(_ score: Int) {
        guard GKLocalPlayer.local.isAuthenticated else { return }
        GKLeaderboard.submitScore(
            score,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [Self.leaderboardID]
        ) { error in
            if let error { print("GameCenter submit error: \(error.localizedDescription)") }
        }
    }
}

// MARK: - Leaderboard Sheet (UIViewControllerRepresentable)

struct GameCenterLeaderboardView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let vc = GKGameCenterViewController(
            leaderboardID: GameCenterManager.leaderboardID,
            playerScope: .global,
            timeScope: .allTime
        )
        vc.gameCenterDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        let parent: GameCenterLeaderboardView
        init(_ parent: GameCenterLeaderboardView) { self.parent = parent }

        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true)
            parent.isPresented = false
        }
    }
}
