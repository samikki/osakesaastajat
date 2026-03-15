import SwiftUI

/// Shows stock split (OSAKEANTI) and bankruptcy (KONKURSSI) events one at a time.
struct PriceEventView: View {
    let events: [String]
    @EnvironmentObject var game: GameModel
    @State private var currentIndex = 0

    var body: some View {
        let isLast = currentIndex >= events.count - 1

        VStack(spacing: 32) {
            Spacer()

            // Event counter
            if events.count > 1 {
                Text("\(currentIndex + 1) / \(events.count)")
                    .font(.vic20Small)
                    .foregroundColor(.white.opacity(0.5))
            }

            // Event box
            VStack(spacing: 16) {
                let isOsakeanti = events[currentIndex].hasPrefix("OSAKEANTI")

                Image(systemName: isOsakeanti ? "arrow.up.circle.fill" : "xmark.circle.fill")
                    .resizable()
                    .frame(width: 56, height: 56)
                    .foregroundColor(isOsakeanti ? .green : .red)

                ForEach(events[currentIndex].components(separatedBy: "\n"), id: \.self) { line in
                    Text(line)
                        .font(.vic20)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.07))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal, 24)

            Spacer()

            Button(isLast ? "UUSI KIERROS" : "SEURAAVA") {
                if isLast {
                    game.continueAfterEvents()
                } else {
                    currentIndex += 1
                }
            }
            .buttonStyle(Vic20ButtonStyle(color: isLast ? .green : .white))
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.vic20Blue)
    }
}
