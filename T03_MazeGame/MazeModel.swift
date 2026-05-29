//
//  MazeModel.swift
//  T03_MazeGame
//

import Foundation
import CoreGraphics

// Each cell has 4 walls: top, right, bottom, left
struct MazeCell {
    var walls: [Bool] = [true, true, true, true] // top, right, bottom, left
    var visited: Bool = false
}

struct MazeModel {
    let cols: Int
    let rows: Int
    var cells: [[MazeCell]]

    // Entry: top-left, Exit: bottom-right
    var entryCol: Int { 0 }
    var entryRow: Int { 0 }
    var exitCol: Int { cols - 1 }
    var exitRow: Int { rows - 1 }

    init(cols: Int, rows: Int) {
        self.cols = cols
        self.rows = rows
        self.cells = Array(repeating: Array(repeating: MazeCell(), count: cols), count: rows)
        generate()
    }

    mutating func generate() {
        var stack: [(Int, Int)] = []
        let startRow = 0
        let startCol = 0
        cells[startRow][startCol].visited = true
        stack.append((startRow, startCol))

        while !stack.isEmpty {
            let (row, col) = stack.last!
            var neighbors: [(Int, Int, Int)] = [] // row, col, wallIndex

            // top
            if row > 0 && !cells[row - 1][col].visited {
                neighbors.append((row - 1, col, 0))
            }
            // right
            if col < cols - 1 && !cells[row][col + 1].visited {
                neighbors.append((row, col + 1, 1))
            }
            // bottom
            if row < rows - 1 && !cells[row + 1][col].visited {
                neighbors.append((row + 1, col, 2))
            }
            // left
            if col > 0 && !cells[row][col - 1].visited {
                neighbors.append((row, col - 1, 3))
            }

            if neighbors.isEmpty {
                stack.removeLast()
            } else {
                let chosen = neighbors[Int.random(in: 0..<neighbors.count)]
                let (nr, nc, wall) = chosen
                // Remove wall between current and chosen
                cells[row][col].walls[wall] = false
                let opposite = [2, 3, 0, 1][wall]
                cells[nr][nc].walls[opposite] = false
                cells[nr][nc].visited = true
                stack.append((nr, nc))
            }
        }

        // Open entry (top of top-left) and exit (bottom of bottom-right)
        cells[entryRow][entryCol].walls[0] = false
        cells[exitRow][exitCol].walls[2] = false
    }
}
