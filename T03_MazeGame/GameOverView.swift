//
//  GameOverView.swift
//  T03_MazeGame
//

import SwiftUI

struct GameOverView: View {
    let totalScore: Int
    let topScores: [ScoreEntry]
    let onRestart: () -> Void

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: isDarkMode ? [Color(white: 0.1), Color(white: 0.2)] : [Color.indigo.opacity(0.8), Color.purple.opacity(0.9)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Text("¡Juego Finalizado!")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                // Final score
                VStack(spacing: 8) {
                    Text("Puntuación Total")
                        .font(.headline)
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(totalScore)")
                        .font(.system(size: 56, weight: .heavy, design: .rounded))
                        .foregroundStyle(.yellow)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                // Top 5 scores
                VStack(alignment: .leading, spacing: 12) {
                    Text("Top 5 Puntuaciones")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .center)

                    ForEach(Array(topScores.enumerated()), id: \.element.id) { index, entry in
                        HStack {
                            Text(medalEmoji(for: index))
                                .font(.title2)
                            Text("#\(index + 1)")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(width: 36, alignment: .leading)
                            Spacer()
                            Text("\(entry.score)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(index == 0 ? Color.yellow : .white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(index == 0 ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                        )
                    }

                    if topScores.isEmpty {
                        Text("Aún no hay puntuaciones")
                            .foregroundStyle(.white.opacity(0.5))
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))

                // Restart button
                Button(action: onRestart) {
                    Label("Jugar de Nuevo", systemImage: "arrow.trianglehead.counterclockwise")
                        .font(.headline)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 14)
                        .background(Color.yellow)
                        .foregroundStyle(Color.black)
                        .clipShape(Capsule())
                        .shadow(radius: 6)
                }
            }
            .padding(24)
        }
    }

    private func medalEmoji(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "🏅"
        }
    }
}
