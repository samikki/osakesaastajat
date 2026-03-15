import SwiftUI

// Multi-step form: player names (2), then company names (12)
struct SetupView: View {
    @EnvironmentObject var game: GameModel

    // Setup steps: 0-1 = player names, 2-13 = company names
    @State private var step = 0
    @State private var playerNames = ["", ""]
    @State private var companyNames = Array(repeating: "", count: 12)
    @State private var inputText = ""
    @State private var errorMessage = ""
    @FocusState private var fieldFocused: Bool

    private var totalSteps: Int { 14 } // 2 players + 12 companies

    private var prompt: String {
        if step < 2 {
            return "PELAAJAN \(step + 1) NIMI:"
        } else {
            return "YHTION \(step - 1) NIMI:"
        }
    }

    private var maxLength: Int { step < 2 ? 6 : 8 }

    private var progressText: String {
        if step < 2 { return "PELAAJAT (\(step + 1)/2)" }
        return "YHTIOT (\(step - 1)/12)"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            Text("*OSAKESAASTAJAT*")
                .font(.vic20Large)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)

            Text(progressText)
                .font(.vic20Small)
                .foregroundColor(.white.opacity(0.6))
                .frame(maxWidth: .infinity)

            Divider().background(Color.white.opacity(0.3))

            // Previously entered names (context)
            if step < 2 {
                ForEach(0..<step, id: \.self) { i in
                    Text("PELAAJA \(i + 1): \(playerNames[i])")
                        .font(.vic20)
                        .foregroundColor(.white.opacity(0.5))
                }
            } else {
                // Show both player names
                ForEach(0..<2, id: \.self) { i in
                    Text("PELAAJA \(i + 1): \(playerNames[i])")
                        .font(.vic20Small)
                        .foregroundColor(.white.opacity(0.5))
                }
                Divider().background(Color.white.opacity(0.2))
                // Show previously entered company names
                ForEach(0..<(step - 2), id: \.self) { i in
                    Text("\(i + 1). \(companyNames[i])")
                        .font(.vic20Small)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // Current prompt
            Text(prompt)
                .font(.vic20)
                .foregroundColor(.white)

            HStack(spacing: 8) {
                Text(">")
                    .font(.vic20)
                    .foregroundColor(.white)

                TextField("", text: $inputText)
                    .font(.vic20)
                    .foregroundColor(.white)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($fieldFocused)
                    .onChange(of: inputText) { newValue in
                        // Enforce max length + uppercase (iOS 16 compatible)
                        let cleaned = String(newValue.uppercased().prefix(maxLength))
                        if inputText != cleaned { inputText = cleaned }
                        errorMessage = ""
                    }
                    .onSubmit { advance() }
                    .submitLabel(.done)
            }
            .padding(8)
            .overlay(Rectangle().stroke(Color.white, lineWidth: 1))

            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .font(.vic20)
                    .foregroundColor(.yellow)
            }

            HStack {
                if step > 0 {
                    Button("TAKAISIN") {
                        step -= 1
                        inputText = ""
                        errorMessage = ""
                    }
                    .buttonStyle(Vic20ButtonStyle(color: .gray))
                }
                Spacer()
                Button("JATKA") { advance() }
                    .buttonStyle(Vic20ButtonStyle())
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
        .onAppear { fieldFocused = true }
    }

    private func advance() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            errorMessage = maxLength == 6 ? "6 KIRJA INTA." : "8 KIRJA INTA."
            return
        }

        if step < 2 {
            playerNames[step] = trimmed
        } else {
            companyNames[step - 2] = trimmed
        }

        step += 1
        inputText = ""
        errorMessage = ""

        if step == totalSteps {
            game.startGame(playerNames: playerNames, companyNames: companyNames)
        } else {
            fieldFocused = true
        }
    }
}
