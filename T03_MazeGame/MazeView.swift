//
//  MazeView.swift
//  T03_MazeGame
//

import SwiftUI

struct MazeView: View {
    let maze: MazeModel
    let ballRow: Int
    let ballCol: Int

    var body: some View {
        GeometryReader { geo in
            let cellSize = min(geo.size.width / CGFloat(maze.cols),
                               geo.size.height / CGFloat(maze.rows))
            let mazeWidth = cellSize * CGFloat(maze.cols)
            let mazeHeight = cellSize * CGFloat(maze.rows)
            let offsetX = (geo.size.width - mazeWidth) / 2
            let offsetY = (geo.size.height - mazeHeight) / 2

            ZStack(alignment: .topLeading) {
                // Maze walls
                Canvas { context, size in
                    let wallColor = Color.primary
                    for row in 0..<maze.rows {
                        for col in 0..<maze.cols {
                            let x = offsetX + CGFloat(col) * cellSize
                            let y = offsetY + CGFloat(row) * cellSize
                            let cell = maze.cells[row][col]

                            // Top wall
                            if cell.walls[0] {
                                var path = Path()
                                path.move(to: CGPoint(x: x, y: y))
                                path.addLine(to: CGPoint(x: x + cellSize, y: y))
                                context.stroke(path, with: .color(wallColor), lineWidth: 2)
                            }
                            // Right wall
                            if cell.walls[1] {
                                var path = Path()
                                path.move(to: CGPoint(x: x + cellSize, y: y))
                                path.addLine(to: CGPoint(x: x + cellSize, y: y + cellSize))
                                context.stroke(path, with: .color(wallColor), lineWidth: 2)
                            }
                            // Bottom wall
                            if cell.walls[2] {
                                var path = Path()
                                path.move(to: CGPoint(x: x, y: y + cellSize))
                                path.addLine(to: CGPoint(x: x + cellSize, y: y + cellSize))
                                context.stroke(path, with: .color(wallColor), lineWidth: 2)
                            }
                            // Left wall
                            if cell.walls[3] {
                                var path = Path()
                                path.move(to: CGPoint(x: x, y: y))
                                path.addLine(to: CGPoint(x: x, y: y + cellSize))
                                context.stroke(path, with: .color(wallColor), lineWidth: 2)
                            }
                        }
                    }
                }

                // Exit marker
                let exitX = offsetX + CGFloat(maze.exitCol) * cellSize
                let exitY = offsetY + CGFloat(maze.exitRow) * cellSize
                Rectangle()
                    .fill(Color.green.opacity(0.4))
                    .frame(width: cellSize, height: cellSize)
                    .position(x: exitX + cellSize / 2, y: exitY + cellSize / 2)

                // Ball
                let ballX = offsetX + CGFloat(ballCol) * cellSize + cellSize / 2
                let ballY = offsetY + CGFloat(ballRow) * cellSize + cellSize / 2
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.white, .blue],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: cellSize * 0.45
                        )
                    )
                    .frame(width: cellSize * 0.7, height: cellSize * 0.7)
                    .shadow(color: .blue.opacity(0.6), radius: 4)
                    .position(x: ballX, y: ballY)
                    .animation(.easeInOut(duration: 0.12), value: ballRow)
                    .animation(.easeInOut(duration: 0.12), value: ballCol)
            }
        }
    }
}
