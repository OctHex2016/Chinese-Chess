//
//  GameManager.swift
//  中國象棋
//

import Foundation
import Combine

class GameManager: ObservableObject {
    @Published var board = Board()
    @Published var currentPlayer: PlayerColor = .red
    @Published var selectedPosition: Position?
    @Published var message: String = ""
    
    func selectPiece(at position: Position) {
        let piece = board.getPiece(at: position)
        
        if let selectedPos = self.selectedPosition {
            if selectedPos == position {
                // 取消選擇
                self.selectedPosition = nil
                self.message = ""
            } else if board.movePiece(from: selectedPos, to: position) {
                // 成功移動
                self.selectedPosition = nil
                self.currentPlayer = currentPlayer == .red ? .black : .red
                self.message = ""
                
                // 檢查將帥對臉
                if board.isKingsFacing() {
                    self.message = "將帥對臉！請更換走法！"
                }
            } else {
                // 無法移動，顯示提示
                self.selectedPosition = nil
                self.message = "走法錯誤！"
            }
        } else if let piece = piece, piece.color == currentPlayer {
            self.selectedPosition = position
            self.message = ""
        }
    }
    
    func resetGame() {
        board = Board()
        currentPlayer = .red
        selectedPosition = nil
        message = ""
    }
}
