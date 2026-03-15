import SwiftUI

struct SellView: View {
    let playerIndex: Int
    @EnvironmentObject var game: GameModel

    @State private var selectedCompany: Int? = nil
    @State private var quantity: Int = 1
    @State private var errorMessage = ""
    @State private var showSellSheet = false

    private var player: Player { game.players[playerIndex] }

    private var heldCompanies: [Company] {
        game.companies.filter { player.holdings[$0.id] > 0 }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerBar

            if heldCompanies.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Text("OSAKKEITA EI OLE.")
                        .font(.vic20)
                        .foregroundColor(.white)
                    Text("(\(player.name):lla ei ole osakkeita)")
                        .font(.vic20Small)
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
                Button("JATKA") {
                    game.doneSelling(playerIndex: playerIndex)
                }
                .buttonStyle(Vic20ButtonStyle())
                .padding(.bottom, 48)
            } else {
                portfolioList
                footerBar
            }
        }
        .background(Color.vic20Blue)
        .sheet(isPresented: $showSellSheet) {
            if let idx = selectedCompany {
                SellSheet(
                    company: game.companies[idx],
                    player: player,
                    quantity: $quantity,
                    errorMessage: $errorMessage,
                    onSell: {
                        let ok = game.sellShares(
                            playerIndex: playerIndex,
                            companyIndex: idx,
                            quantity: quantity
                        )
                        if ok {
                            showSellSheet = false
                            errorMessage = ""
                        } else {
                            errorMessage = "EI OLE."
                        }
                    },
                    onCancel: {
                        showSellSheet = false
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
            Text("\(player.name):N OSAKKEET")
                .font(.vic20)
                .foregroundColor(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.3))
    }

    private var portfolioList: some View {
        ScrollView {
            VStack(spacing: 0) {
                portfolioHeader
                ForEach(heldCompanies) { company in
                    portfolioRow(company: company)
                        .onTapGesture {
                            selectedCompany = company.id
                            quantity = 1
                            errorMessage = ""
                            showSellSheet = true
                        }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var portfolioHeader: some View {
        HStack(spacing: 0) {
            Text("N:O").font(.vic20Small).foregroundColor(.white.opacity(0.7))
                .frame(width: 32, alignment: .leading)
            Text("NIMI    ").font(.vic20Small).foregroundColor(.white.opacity(0.7))
            Spacer()
            Text("KPL").font(.vic20Small).foregroundColor(.white.opacity(0.7))
                .frame(width: 44, alignment: .trailing)
            Text("ARVO").font(.vic20Small).foregroundColor(.white.opacity(0.7))
                .frame(width: 56, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.black.opacity(0.2))
    }

    private func portfolioRow(company: Company) -> some View {
        let held = player.holdings[company.id]
        let value = held * company.price
        return HStack(spacing: 0) {
            Text("\(company.id + 1)")
                .font(.vic20Small)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 32, alignment: .leading)
            Text(company.name.padding(toLength: 9, withPad: " ", startingAt: 0))
                .font(.vic20Small)
                .foregroundColor(.white)
            Spacer()
            Text("\(held)")
                .font(.vic20Small)
                .foregroundColor(.white)
                .frame(width: 44, alignment: .trailing)
            Text("\(value)")
                .font(.vic20Small)
                .foregroundColor(.yellow)
                .frame(width: 56, alignment: .trailing)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.05))
        .overlay(Rectangle().stroke(Color.white.opacity(0.08), lineWidth: 0.5))
    }

    private var footerBar: some View {
        VStack(spacing: 8) {
            Text("MYYTKO? (Napauta yhtiötä)")
                .font(.vic20)
                .foregroundColor(.white)
            Text("VARAT: \(player.capital) MK")
                .font(.vic20Small)
                .foregroundColor(.yellow)

            Button("VALMIS – EI MYYNTIÄ") {
                game.doneSelling(playerIndex: playerIndex)
            }
            .buttonStyle(Vic20ButtonStyle(color: .green))
            .padding(.bottom, 8)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color.black.opacity(0.3))
    }
}

// MARK: - Sell Sheet

struct SellSheet: View {
    let company: Company
    let player: Player
    @Binding var quantity: Int
    @Binding var errorMessage: String
    let onSell: () -> Void
    let onCancel: () -> Void

    private var held: Int { player.holdings[company.id] }
    private var proceeds: Int { quantity * company.price }
    private var canSell: Bool { quantity <= held && quantity > 0 }

    var body: some View {
        VStack(spacing: 20) {
            Text("MYYNTI")
                .font(.vic20Large)
                .foregroundColor(.white)

            Divider().background(Color.white.opacity(0.3))

            VStack(alignment: .leading, spacing: 8) {
                Text("YHTIO:    \(company.name)")
                Text("HINTA:    \(company.price) MK/kpl")
                Text("OMISTUS:  \(held) kpl")
                Text("VARAT:    \(player.capital) MK")
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
                    if quantity < held { quantity += 1 }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 36, height: 36)
                        .foregroundColor(.white)
                }
            }

            // Sell all button
            Button("MYYN KAIKKI (\(held) KPL)") {
                quantity = held
            }
            .buttonStyle(Vic20ButtonStyle(color: .orange))

            // Proceeds
            VStack(spacing: 4) {
                Text("SAATU: \(proceeds) MK")
                    .font(.vic20)
                    .foregroundColor(canSell ? .white : .red)
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.vic20)
                        .foregroundColor(.yellow)
                }
            }

            HStack(spacing: 16) {
                Button("PERUUTA") { onCancel() }
                    .buttonStyle(Vic20ButtonStyle(color: .gray))

                Button("MYYN") { onSell() }
                    .buttonStyle(Vic20ButtonStyle(color: canSell ? .white : .gray))
                    .disabled(!canSell)
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
    }
}
