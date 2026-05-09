//
//  Board.swift
//  中國象棋
//

import Foundation
import Combine

struct Position: Equatable {
    let row: Int
    let column: Int
    
    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }
    
    static func == (lhs: Position, rhs: Position) -> Bool {
        return lhs.row == rhs.row && lhs.column == rhs.column
    }
}

class Board: ObservableObject {
    @Published var pieces: [[Piece?]] = Array(repeating: Array(repeating: nil, count: 9), count: 10)
    
    init() {
        setupInitialBoard()
    }
    
    private func setupInitialBoard() {
        // Clear board
        pieces = Array(repeating: Array(repeating: nil, count: 9), count: 10)
        
        // Set up red pieces (bottom - rows 9, 8, 7, 6)
        // Row 9 (bottom row)
        pieces[9][0] = Piece(type: .chariot, color: .red)
        pieces[9][1] = Piece(type: .horse, color: .red)
        pieces[9][2] = Piece(type: .elephant, color: .red)
        pieces[9][3] = Piece(type: .advisor, color: .red)
        pieces[9][4] = Piece(type: .general, color: .red)
        pieces[9][5] = Piece(type: .advisor, color: .red)
        pieces[9][6] = Piece(type: .elephant, color: .red)
        pieces[9][7] = Piece(type: .horse, color: .red)
        pieces[9][8] = Piece(type: .chariot, color: .red)
        
        // Row 7 (third row from bottom)
        pieces[7][1] = Piece(type: .cannon, color: .red)
        pieces[7][7] = Piece(type: .cannon, color: .red)
        
        // Row 6 (fourth row from bottom)
        pieces[6][0] = Piece(type: .soldier, color: .red)
        pieces[6][2] = Piece(type: .soldier, color: .red)
        pieces[6][4] = Piece(type: .soldier, color: .red)
        pieces[6][6] = Piece(type: .soldier, color: .red)
        pieces[6][8] = Piece(type: .soldier, color: .red)
        
        // Set up black pieces (top - rows 0, 1, 2, 3)
        // Row 0 (top row)
        pieces[0][0] = Piece(type: .chariot, color: .black)
        pieces[0][1] = Piece(type: .horse, color: .black)
        pieces[0][2] = Piece(type: .elephant, color: .black)
        pieces[0][3] = Piece(type: .advisor, color: .black)
        pieces[0][4] = Piece(type: .general, color: .black)
        pieces[0][5] = Piece(type: .advisor, color: .black)
        pieces[0][6] = Piece(type: .elephant, color: .black)
        pieces[0][7] = Piece(type: .horse, color: .black)
        pieces[0][8] = Piece(type: .chariot, color: .black)
        
        // Row 2 (third row from top)
        pieces[2][1] = Piece(type: .cannon, color: .black)
        pieces[2][7] = Piece(type: .cannon, color: .black)
        
        // Row 3 (fourth row from top)
        pieces[3][0] = Piece(type: .soldier, color: .black)
        pieces[3][2] = Piece(type: .soldier, color: .black)
        pieces[3][4] = Piece(type: .soldier, color: .black)
        pieces[3][6] = Piece(type: .soldier, color: .black)
        pieces[3][8] = Piece(type: .soldier, color: .black)
    }
    
    func getPiece(at position: Position) -> Piece? {
        guard position.row >= 0 && position.row < 10,
              position.column >= 0 && position.column < 9 else {
            return nil
        }
        return pieces[position.row][position.column]
    }
    
    // 統計兩點之間的棋子數量 (只用於直線移動)
    private func countPiecesBetween(from: Position, to: Position) -> Int {
        var count = 0
        
        if from.row == to.row && from.column != to.column {
            // 水平移動 (只處理不同位置)
            let startCol = min(from.column, to.column)
            let endCol = max(from.column, to.column)
            for c in (startCol + 1)..<endCol {
                if pieces[from.row][c] != nil {
                    count += 1
                }
            }
        } else if from.column == to.column && from.row != to.row {
            // 垂直移動 (只處理不同位置)
            let startRow = min(from.row, to.row)
            let endRow = max(from.row, to.row)
            for r in (startRow + 1)..<endRow {
                if pieces[r][from.column] != nil {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    // 檢查是否可以移動
    func canMove(from: Position, to: Position) -> Bool {
        guard let piece = pieces[from.row][from.column] else { return false }
        
        // 不能吃己方棋子
        if let targetPiece = pieces[to.row][to.column], targetPiece.color == piece.color {
            return false
        }
        
        let rowDiff = to.row - from.row
        let colDiff = abs(to.column - from.column)
        
        switch piece.type {
        case .general: // 將/帥 - 每次走一步，九宮內直行或橫行
            if abs(rowDiff) + abs(colDiff) != 1 {
                return false
            }
            return piece.isInPalace(row: to.row, column: to.column)
            
        case .advisor: // 士/仕 - 每次斜走一步，九宮內
            if abs(rowDiff) == 1 && abs(colDiff) == 1 {
                return piece.isInPalace(row: to.row, column: to.column)
            }
            return false
            
        case .elephant: // 相/象 - 走田字，不能過河，塞象眼
            if abs(rowDiff) == 2 && abs(colDiff) == 2 {
                let midRow = from.row + rowDiff / 2
                let midCol = from.column + colDiff / 2
                if pieces[midRow][midCol] == nil && !piece.isAcrossRiver(row: to.row) {
                    return true
                }
            }
            return false
            
        case .horse: // 馬 - 走日字，蹩馬腿
            let validMoves: [(Int, Int)] = [(-2, -1), (-2, 1), (-1, -2), (-1, 2), (1, -2), (1, 2), (2, -1), (2, 1)]
            for (dr, dc) in validMoves {
                if from.row + dr == to.row && from.column + dc == to.column {
                    let legRow: Int
                    let legCol: Int
                    if abs(dr) == 2 {
                        legRow = from.row + dr / 2
                        legCol = from.column
                    } else {
                        legRow = from.row
                        legCol = from.column + dc / 2
                    }
                    if pieces[legRow][legCol] == nil {
                        return true
                    }
                }
            }
            return false
            
        case .chariot: // 車 - 直線不限距離
            if from.row == to.row || from.column == to.column {
                return countPiecesBetween(from: from, to: to) == 0
            }
            return false
            
        case .cannon: // 炮 - 直線移動，吃子需有炮架
            if from.row == to.row || from.column == to.column {
                let piecesBetween = countPiecesBetween(from: from, to: to)
                if pieces[to.row][to.column] == nil {
                    return piecesBetween == 0
                } else {
                    return piecesBetween == 1
                }
            }
            return false
            
        case .soldier: // 兵/卒 - 過河前只前進，過河後可左右
            if abs(rowDiff) + abs(colDiff) != 1 {
                return false
            }
            let forwardDirection: Int = piece.color == .red ? -1 : 1
            if colDiff == 1 {
                return piece.isAcrossRiver(row: from.row)
            } else {
                return rowDiff == forwardDirection
            }
        }
    }
    
    func movePiece(from: Position, to: Position) -> Bool {
        guard canMove(from: from, to: to) else { return false }
        
        pieces[to.row][to.column] = pieces[from.row][from.column]
        pieces[from.row][from.column] = nil
        return true
    }
    
    // 檢查將帥是否對臉
    func isKingsFacing() -> Bool {
        var redGeneral: Position? = nil
        var blackGeneral: Position? = nil
        
        for row in 0..<10 {
            for col in 0..<9 {
                if let piece = pieces[row][col] {
                    if piece.type == .general && piece.color == .red {
                        redGeneral = Position(row: row, column: col)
                    } else if piece.type == .general && piece.color == .black {
                        blackGeneral = Position(row: row, column: col)
                    }
                }
            }
        }
        
        guard let red = redGeneral, let black = blackGeneral else { return false }
        
        if red.column == black.column {
            for r in (min(red.row, black.row) + 1)..<max(red.row, black.row) {
                if pieces[r][red.column] != nil {
                    return false
                }
            }
            return true
        }
        
        return false
    }
}
