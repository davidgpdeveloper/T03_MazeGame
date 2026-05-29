//
//  ContentView.swift
//  T03_MazeGame
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = GameState()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    // Drag gesture state
    @GestureState private var dragOffset: CGSize = .zero

    private let dragThreshold: CGFloat = 20

    var body: some View {
        ZStack {
            mainContent
            if game.phase == .fireworks {
                FireworksView()
                    .transition(.opacity)
                    .allowsHitTesting(false)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: game.phase)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch game.phase {
        case .playing, .fireworks:
            gameView
        case .gameOver:
            GameOverView(
                totalScore: game.totalScore,
                topScores: game.topScores,
                onRestart: { game.restartGame() }
            )
        }
    }

    private var gameView: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar
                .padding(.horizontal)
                .padding(.top, 8)

            // Info bar
            infoBar
                .padding(.horizontal)
                .padding(.top, 4)

            // Maze
            MazeView(
                maze: game.maze,
                ballRow: game.ballRow,
                ballCol: game.ballCol
            )
            .padding(12)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .gesture(dragGesture)
            .disabled(game.phase != .playing)

            // Arrow controls
            arrowControls
                .padding(.bottom, 20)
        }
        .background(Color(uiColor: .systemBackground))
    }

    private var topBar: some View {
        HStack {
            Text("Laberinto \(game.currentLevel)/\(GameState.totalLevels)")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            Spacer()

            // Dark/Light mode toggle
            Button {
                isDarkMode.toggle()
            } label: {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.title2)
                    .foregroundStyle(isDarkMode ? Color.indigo : Color.orange)
                    .animation(.easeInOut(duration: 0.3), value: isDarkMode)
            }
        }
    }

    private var infoBar: some View {
        HStack(spacing: 16) {
            // Timer
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .foregroundStyle(timerColor)
                Text(String(format: "%.0f s", max(0, game.timeRemaining)))
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundStyle(timerColor)
            }

            // Timer bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.secondary.opacity(0.2))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(timerColor)
                        .frame(width: geo.size.width * CGFloat(game.timeRemaining / GameState.levelDuration))
                        .animation(.linear(duration: 0.1), value: game.timeRemaining)
                }
            }
            .frame(height: 8)

            // Score
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text("\(game.levelScore)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
    }

    private var timerColor: Color {
        let ratio = game.timeRemaining / GameState.levelDuration
        if ratio > 0.5 { return .green }
        if ratio > 0.25 { return .orange }
        return .red
    }

    private var arrowControls: some View {
        VStack(spacing: 8) {
            directionButton(image: "arrow.up", dRow: -1, dCol: 0)
            HStack(spacing: 32) {
                directionButton(image: "arrow.left", dRow: 0, dCol: -1)
                directionButton(image: "arrow.down", dRow: 1, dCol: 0)
                directionButton(image: "arrow.right", dRow: 0, dCol: 1)
            }
        }
    }

    private func directionButton(image: String, dRow: Int, dCol: Int) -> some View {
        Button {
            game.tryMove(dRow: dRow, dCol: dCol)
        } label: {
            Image(systemName: image)
                .font(.system(size: 24, weight: .bold))
                .frame(width: 56, height: 56)
                .background(Color.accentColor.opacity(0.15))
                .foregroundStyle(Color.accentColor)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
                )
        }
        .disabled(game.phase != .playing)
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: dragThreshold)
            .onEnded { value in
                let h = value.translation.width
                let v = value.translation.height
                if abs(h) > abs(v) {
                    game.tryMove(dRow: 0, dCol: h > 0 ? 1 : -1)
                } else {
                    game.tryMove(dRow: v > 0 ? 1 : -1, dCol: 0)
                }
            }
    }
}

#Preview {
    ContentView()
}
