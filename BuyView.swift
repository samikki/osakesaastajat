import SwiftUI

struct BuyView: View {
    let playerIndex: Int
    @EnvironmentObject var game: GameModel

    @State private var selectedCompany: Int? = nil
    @State private var quantity: Int = 1
    @State private var errorMessage = ""
    @State private var showBuySheet = false

    private var player: Player { game.players[playerIndex] }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerBar

            // Market table
            ScrollView {
                VStack(spacing: 0) {
                    marketHeader
                    ForEach(game.companies) { company in
                        marketRow(company: company)
                            .onTapGesture {
                                selectedCompany = company.id
                                quantity = 1
                                errorMessage = ""
                                showBuySheet = true
                            }
                    }
                }
                .padding(.horizontal, 4)
            }

            // Footer status
            footerBar
        }
        .background(Color.vic20Blue)
        .sheet(isPresented: $showBuySheet) {
            if let idx = selectedCompany {
                BuySheet(
                    company: game.companies[idx],
                    player: player,
                    quantity: $quantity,
                    errorMessage: $errorMessage,
                    onBuy: {
                        let ok = game.buyShares(
                            playerIndex: playerIndex,
                            companyIndex: idx,
                            quantity: quantity
                        )
                        if ok {
                            showBuySheet = false
                            errorMessage = ""
                        } else {
                            errorMessage = "EI VARAA."
                        }
                    },
                    onCancel: {
                        showBuySheet = false
                        errorMessage = ""
                    }
                )
                .presentationDetents([.medium])
            }
        }
    }

    private var headerBar: some View {
        HStack {
            Text("KIERROS \(game.round)")
                .font(.vic20Small)
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text("PELAAJA \(playerIndex + 1): \(player.name)")
                .font(.vic20)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }

    private var marketHeader: some View {
        HStack(spacing: 0) {
            Text("YHTIO   ").font(.vic20Small).foregroundColor(.white.opacity(0.7))
            Text(" MUU").font(.vic20Small).foregroundColor(.white.opacity(0.7))
            Spacer()
            Text("HINTA").font(.vic20Small).foregroundColor(.white.opacity(0.7))
            Text("  N:O").font(.vic20Small).foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.2))
    }

    private func marketRow(company: Company) -> some View {
        HStack(spacing: 0) {
            Text(company.name.padding(toLength: 8, withPad: " ", startingAt: 0))
                .font(.vic20Small)
                .foregroundColor(.white)

            changeLabel(company.priceChange)
                .frame(width: 32, alignment: .trailing)

            Spacer()

            Text("\(company.price)")
                .font(.vic20Small)
                .foregroundColor(.white)
                .frame(width: 40, alignment: .trailing)

            Text("\(company.id + 1)")
                .font(.vic20Small)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 28, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.05))
        .overlay(Rectangle().stroke(Color.white.opacity(0.08), lineWidth: 0.5))
    }

    private func changeLabel(_ change: Int) -> some View {
        Group {
            if change > 0 {
                Text("+\(change * 10)")
                    .foregroundColor(.green)
            } else if change < 0 {
                Text("\(change * 10)")
                    .foregroundColor(.red)
            } else {
                Text("  0")
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .font(.vic20Small)
    }

    private var footerBar: some View {
        VStack(spacing: 8) {
            Text("TEKEEKO \(player.name) OSTOJA?")
                .font(.vic20)
                .foregroundColor(.white)
            Text("VARAT: \(player.capital) MK")
                .font(.vic20Small)
                .foregroundColor(.yellow)
            Text("(Napauta yhtiötä ostaaksesi)")
                .font(.system(.caption2, design: .monospaced))
                .foregroundColor(.white.opacity(0.5))

            Button("VALMIS – EI OSTOJA") {
                game.doneBuying(playerIndex: playerIndex)
            }
            .buttonStyle(Vic20ButtonStyle(color: .green))
            .padding(.bottom, 8)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
    }
}

// MARK: - Buy Sheet

struct BuySheet: View {
    let company: Company
    let player: Player
    @Binding var quantity: Int
    @Binding var errorMessage: String
    let onBuy: () -> Void
    let onCancel: () -> Void

    private var cost: Int { quantity * company.price }
    private var canAfford: Bool { cost <= player.capital }

    var body: some View {
        VStack(spacing: 20) {
            Text("OSTA OSAKKEITA")
                .font(.vic20Large)
                .foregroundColor(.white)

            Divider().background(Color.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 8) {
                Text("YHTIO:  \(company.name)")
                Text("HINTA:  \(company.price) MK/kpl")
                Text("VARAT:  \(player.capital) MK")
            }
            .font(.vic20)
            .foregroundColor(.white)

            // Quantity stepper
            HStack(spacing: 24) {
                Button {
                    if quantity > 1 { quantity -= 1 }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white)
                }

                Text("\(quantity) KPL")
                    .font(.vic20Large)
                    .foregroundColor(.white)
                    .frame(minWidth: 80)

                Button {
                    quantity += 1
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white)
                }
            }

            // Fast quantity buttons
            HStack(spacing: 8) {
                ForEach([5, 10, 50], id: \.self) { n in
                    Button("+\(n)") { quantity += n }
                        .buttonStyle(Vic20ButtonStyle(color: .white.opacity(0.6)))
                }
            }

            // Cost
            VStack(spacing: 4) {
                Text("HINTA YHT: \(cost) MK")
                    .font(.vic20)
                    .foregroundColor(canAfford ? .white : .red)
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.vic20)
                        .foregroundColor(.yellow)
                }
            }

            HStack(spacing: 16) {
                Button("PERUUTA") { onCancel() }
                    .buttonStyle(Vic20ButtonStyle(color: .gray))

                Button("OSTA") { onBuy() }
                    .buttonStyle(Vic20ButtonStyle(color: canAfford ? .white : .gray))
                    .disabled(!canAfford)
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
    }
}
