//
//  StartView.swift
//  T03_MazeGame
//

import SwiftUI

struct StartView: View {
    let topScores: [ScoreEntry]
    let onStart: () -> Void

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                // Title
                VStack(spacing: 6) {
                    Text("🌀")
                        .font(.system(size: 64))
                    Text("Maze Game")
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)
                    Text("¿Puedes superar los 10 laberintos?")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }

                // Top 5
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundStyle(.yellow)
                        Text("Mejores Puntuaciones")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }

                    if topScores.isEmpty {
                        Text("Aún no hay puntuaciones.\n¡Sé el primero!")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.55))
                            .multilineTextAlignment(.center)
                            .padding(.vertical, 12)
                    } else {
                        ForEach(Array(topScores.enumerated()), id: \.element.id) { index, entry in
                            HStack {
                                Text(medalEmoji(for: index))
                                    .font(.title3)
                                Text("#\(index + 1)")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.55))
                                    .frame(width: 32, alignment: .leading)
                                Spacer()
                                Text("\(entry.score) pts")
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(index == 0 ? Color.yellow : .white)
                                Text(formattedDate(entry.date))
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.45))
                                    .frame(width: 72, alignment: .trailing)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(index == 0 ? Color.yellow.opacity(0.18) : Color.white.opacity(0.08))
                            )
                        }
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))

                Spacer()

                // Start button
                Button(action: onStart) {
                    HStack(spacing: 10) {
                        Image(systemName: "play.fill")
                        Text("Iniciar Partida")
                            .fontWeight(.bold)
                    }
                    .font(.title3)
                    .foregroundStyle(.black)
                    .padding(.horizontal, 48)
                    .padding(.vertical, 16)
                    .background(Color.yellow)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.3), radius: 8, y: 4)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 24)

            // Dark/Light toggle
            VStack {
                HStack {
                    Spacer()
                    Button {
                        isDarkMode.toggle()
                    } label: {
                        Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                            .font(.title2)
                            .foregroundStyle(isDarkMode ? Color.indigo : Color.orange)
                            .padding(12)
                            .background(.ultraThinMaterial, in: Circle())
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 8)
                }
                Spacer()
            }
        }
    }

    private var background: some View {
        LinearGradient(
            colors: isDarkMode
                ? [Color(white: 0.08), Color(white: 0.18)]
                : [Color.indigo, Color.purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func medalEmoji(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "🏅"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "dd/MM/yy"
        return f.string(from: date)
    }
}

#Preview {
    StartView(topScores: [
        ScoreEntry(score: 8500),
        ScoreEntry(score: 7200),
        ScoreEntry(score: 5000),
    ], onStart: {})
}
