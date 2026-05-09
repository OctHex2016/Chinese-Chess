//
//  Piece.swift
//  中國象棋
//

import Foundation

enum PieceType: String, CaseIterable {
    case general = "帥"     // 帥 (General)
    case advisor = "仕"     // 仕 (Advisor)
    case elephant = "相"    // 相 (Elephant)
    case horse = "馬"       // 馬 (Horse)
    case chariot = "車"     // 車 (Chariot)
    case cannon = "炮"      // 炮 (Cannon)
    case soldier = "兵"     // 兵 (Soldier)
    
    var redName: String {
        switch self {
        case .general: return "帥"
        case .advisor: return "仕"
        case .elephant: return "相"
        case .horse: return "馬"
        case .chariot: return "車"
        case .cannon: return "炮"
        case .soldier: return "兵"
        }
    }
    
    var blackName: String {
        switch self {
        case .general: return "將"
        case .advisor: return "士"
        case .elephant: return "象"
        case .horse: return "馬"
        case .chariot: return "車"
        case .cannon: return "炮"
        case .soldier: return "卒"
        }
    }
}

enum PlayerColor {
    case red
    case black
}

struct Piece {
    let type: PieceType
    let color: PlayerColor
    var name: String {
        color == .red ? type.redName : type.blackName
    }
    
    init(type: PieceType, color: PlayerColor) {
        self.type = type
        self.color = color
    }
    
    // 檢查是否在九宮範圍內
    func isInPalace(row: Int, column: Int) -> Bool {
        let inRedPalace = (row >= 7 && row <= 9) && (column >= 3 && column <= 5)
        let inBlackPalace = (row >= 0 && row <= 2) && (column >= 3 && column <= 5)
        return (color == .red && inRedPalace) || (color == .black && inBlackPalace)
    }
    
    // 檢查是否過河（紅方在上面，黑方在下面）
    func isAcrossRiver(row: Int) -> Bool {
        return (color == .red && row <= 4) || (color == .black && row >= 5)
    }
}
