import Foundation

// MARK: - Game Phase

enum GamePhase: Equatable {
    case title
    case setup
    case buying(Int)          // player index
    case selling(Int)         // player index
    case dividends
    case priceEvents([String]) // event messages (splits, bankruptcies)
    case askQuit
    case endGame

    static func == (lhs: GamePhase, rhs: GamePhase) -> Bool {
        switch (lhs, rhs) {
        case (.title, .title), (.setup, .setup),
             (.dividends, .dividends), (.askQuit, .askQuit), (.endGame, .endGame):
            return true
        case (.buying(let a), .buying(let b)), (.selling(let a), .selling(let b)):
            return a == b
        case (.priceEvents(let a), .priceEvents(let b)):
            return a == b
        default:
            return false
        }
    }
}

// MARK: - Company

struct Company: Identifiable {
    let id: Int
    var name: String
    var price: Int = 100
    var priceChange: Int = 0
}

// MARK: - Player

struct Player: Identifiable {
    let id: Int
    var name: String
    var capital: Int = 1200
    var holdings: [Int]

    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.holdings = Array(repeating: 0, count: 12)
    }
}

// MARK: - GameModel

class GameModel: ObservableObject {
    @Published var phase: GamePhase = .title
    @Published var players: [Player] = []
    @Published var companies: [Company] = (0..<12).map { Company(id: $0, name: "") }
    @Published var round: Int = 1

    // MARK: - Setup

    func startGame(playerNames: [String], companyNames: [String]) {
        players = playerNames.enumerated().map { Player(id: $0.offset, name: $0.element) }
        companies = companyNames.enumerated().map { i, name in
            Company(id: i, name: name)
        }
        round = 1
        phase = .buying(0)
    }

    // MARK: - Buy Phase

    /// Returns false if player cannot afford the purchase
    @discardableResult
    func buyShares(playerIndex: Int, companyIndex: Int, quantity: Int) -> Bool {
        let cost = quantity * companies[companyIndex].price
        guard players[playerIndex].capital >= cost else { return false }
        players[playerIndex].capital -= cost
        players[playerIndex].holdings[companyIndex] += quantity
        return true
    }

    func doneBuying(playerIndex: Int) {
        phase = .selling(playerIndex)
    }

    // MARK: - Sell Phase

    /// Returns false if player does not hold enough shares
    @discardableResult
    func sellShares(playerIndex: Int, companyIndex: Int, quantity: Int) -> Bool {
        guard players[playerIndex].holdings[companyIndex] >= quantity else { return false }
        players[playerIndex].holdings[companyIndex] -= quantity
        players[playerIndex].capital += quantity * companies[companyIndex].price
        return true
    }

    func doneSelling(playerIndex: Int) {
        if playerIndex == 0 {
            phase = .buying(1)
        } else {
            phase = .dividends
        }
    }

    // MARK: - Dividends
    // Original: d(t,i) * (a(i) / 10)  — integer division

    func payDividends() {
        for t in 0..<2 {
            for i in 0..<12 {
                let shares = players[t].holdings[i]
                if shares > 0 {
                    players[t].capital += shares * (companies[i].price / 10)
                }
            }
        }
        phase = .askQuit
    }

    // MARK: - Price Update (runs only if player chose NOT to quit)

    func startNewRound() {
        let events = updatePrices()
        round += 1
        if events.isEmpty {
            phase = .buying(0)
        } else {
            phase = .priceEvents(events)
        }
    }

    private func updatePrices() -> [String] {
        var events: [String] = []
        for i in 0..<12 {
            let change = Int.random(in: -3...3)
            companies[i].priceChange = change
            companies[i].price += 10 * change

            if companies[i].price >= 200 {
                events.append("OSAKEANTI!\n\(companies[i].name)\nKAKSINKERTAISTAA OSAKKEENSA.")
                for t in 0..<2 { players[t].holdings[i] *= 2 }
                companies[i].price = 100
                companies[i].priceChange = 0
            } else if companies[i].price <= 0 {
                events.append("\(companies[i].name)\nTEKI KONKURSSIN.\nMENETITTE OSAKKEENNE.")
                for t in 0..<2 { players[t].holdings[i] = 0 }
                companies[i].price = 100
                companies[i].priceChange = 0
            }
        }
        return events
    }

    func continueAfterEvents() {
        phase = .buying(0)
    }

    // MARK: - End Game

    func totalWealth(playerIndex: Int) -> Int {
        var total = players[playerIndex].capital
        for i in 0..<12 {
            total += players[playerIndex].holdings[i] * companies[i].price
        }
        return total
    }

    var winnerScore: Int {
        max(totalWealth(playerIndex: 0), totalWealth(playerIndex: 1))
    }

    /// Returns winning player name, or nil for a tie.
    var winnerName: String? {
        let w0 = totalWealth(playerIndex: 0)
        let w1 = totalWealth(playerIndex: 1)
        if w0 == w1 { return nil }
        return w0 > w1 ? players[0].name : players[1].name
    }

    func triggerEndGame() {
        phase = .endGame
    }

    func resetToTitle() {
        players = []
        companies = (0..<12).map { Company(id: $0, name: "") }
        round = 1
        phase = .title
    }
}
