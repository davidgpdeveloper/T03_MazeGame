//
//  GameState.swift
//  T03_MazeGame
//

import Foundation
import Combine

enum GamePhase {
    case start
    case playing
    case fireworks
    case gameOver
}

struct ScoreEntry: Codable, Identifiable {
    let id: UUID
    let score: Int
    let date: Date

    init(score: Int) {
        self.id = UUID()
        self.score = score
        self.date = Date()
    }
}

class GameState: ObservableObject {
    static let mazeCols = 10
    static let mazeRows = 14
    static let totalLevels = 10
    static let levelDuration: Double = 60

    @Published var maze: MazeModel = MazeModel(cols: mazeCols, rows: mazeRows)
    @Published var ballRow: Int = 0
    @Published var ballCol: Int = 0
    @Published var currentLevel: Int = 1
    @Published var timeRemaining: Double = levelDuration
    @Published var levelScore: Int = 1000
    @Published var totalScore: Int = 0
    @Published var phase: GamePhase = .playing
    @Published var topScores: [ScoreEntry] = []

    private var timer: AnyCancellable?

    init() {
        loadScores()
        phase = .start
    }

    func startLevel() {
        maze = MazeModel(cols: GameState.mazeCols, rows: GameState.mazeRows)
        ballRow = 0
        ballCol = 0
        timeRemaining = GameState.levelDuration
        levelScore = 1000
        phase = .playing
        startTimer()
    }

    private func startTimer() {
        timer?.cancel()
        timer = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self, self.phase == .playing else { return }
                self.timeRemaining -= 0.1
                self.levelScore = max(0, Int(1000.0 * (self.timeRemaining / GameState.levelDuration)))
                if self.timeRemaining <= 0 {
                    self.timeRemaining = 0
                    self.levelScore = 0
                    self.endGame()
                }
            }
    }

    func tryMove(dRow: Int, dCol: Int) {
        guard phase == .playing else { return }
        let newRow = ballRow + dRow
        let newCol = ballCol + dCol
        guard newRow >= 0, newRow < GameState.mazeRows,
              newCol >= 0, newCol < GameState.mazeCols else {
            // Allow exiting through the exit opening
            if ballRow == maze.exitRow && ballCol == maze.exitCol && dRow == 1 {
                reachExit()
            }
            return
        }

        // Determine wall index based on direction
        let wallIndex: Int
        if dRow == -1 { wallIndex = 0 }      // top
        else if dCol == 1 { wallIndex = 1 }  // right
        else if dRow == 1 { wallIndex = 2 }  // bottom
        else { wallIndex = 3 }               // left

        if !maze.cells[ballRow][ballCol].walls[wallIndex] {
            ballRow = newRow
            ballCol = newCol
            checkExit()
        }
    }

    private func checkExit() {
        if ballRow == maze.exitRow && ballCol == maze.exitCol {
            reachExit()
        }
    }

    private func reachExit() {
        timer?.cancel()
        totalScore += levelScore
        phase = .fireworks
        // After 3 seconds move to next level or game over
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            if self.currentLevel >= GameState.totalLevels {
                self.endGame()
            } else {
                self.currentLevel += 1
                self.startLevel()
            }
        }
    }

    private func endGame() {
        timer?.cancel()
        saveScore(totalScore)
        phase = .gameOver
    }

    func restartGame() {
        currentLevel = 1
        totalScore = 0
        phase = .start
    }

    func beginGame() {
        currentLevel = 1
        totalScore = 0
        startLevel()
    }

    // MARK: - Persistence
    private let scoresKey = "mazeTopScores"

    private func loadScores() {
        if let data = UserDefaults.standard.data(forKey: scoresKey),
           let decoded = try? JSONDecoder().decode([ScoreEntry].self, from: data) {
            topScores = decoded
        }
    }

    private func saveScore(_ score: Int) {
        var entries = topScores
        entries.append(ScoreEntry(score: score))
        entries.sort { $0.score > $1.score }
        topScores = Array(entries.prefix(5))
        if let encoded = try? JSONEncoder().encode(topScores) {
            UserDefaults.standard.set(encoded, forKey: scoresKey)
        }
    }
}
