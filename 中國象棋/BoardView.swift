//
//  BoardView.swift
//  中國象棋
//

import SwiftUI

// MARK: - 主視圖

struct BoardView: View {
    @StateObject private var gameManager = GameManager()

    var body: some View {
        ZStack {
            // 整體背景 — 深木色
            LinearGradient(
                colors: [Color(red: 0.18, green: 0.12, blue: 0.08),
                         Color(red: 0.08, green: 0.05, blue: 0.03)],
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 12) {
                infoBar
                if !gameManager.message.isEmpty {
                    Text(gameManager.message)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(
                            Capsule().fill(Color.red.opacity(0.85))
                        )
                        .transition(.opacity)
                }
                BoardGridView(gameManager: gameManager)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(12)
        }
    }

    private var infoBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Circle()
                    .fill(gameManager.currentPlayer == .red ? Color.red : Color.black)
                    .frame(width: 14, height: 14)
                    .overlay(Circle().stroke(Color.white.opacity(0.6), lineWidth: 1))
                Text(gameManager.currentPlayer == .red ? "紅方行棋" : "黑方行棋")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }

            Spacer()

            Button {
                gameManager.resetGame()
            } label: {
                Text("重新開局")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        Capsule().fill(Color.white.opacity(0.15))
                    )
                    .overlay(
                        Capsule().stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.25))
        )
    }
}

// MARK: - 棋盤本體

struct BoardGridView: View {
    @ObservedObject var gameManager: GameManager

    // 棋盤外圍 padding（相對 cellSize 的比例）
    private let marginRatio: CGFloat = 0.55

    var body: some View {
        GeometryReader { geometry in
            // 計算 cellSize：棋面要 8 cell 闊、9 cell 高，再加上左右上下嘅外框 margin
            let totalCellsW = 8 + 2 * marginRatio
            let totalCellsH = 9 + 2 * marginRatio
            let cellSize = min(geometry.size.width / totalCellsW,
                               geometry.size.height / totalCellsH)

            let boardWidth = 8 * cellSize
            let boardHeight = 9 * cellSize
            let margin = marginRatio * cellSize
            let frameWidth = boardWidth + 2 * margin
            let frameHeight = boardHeight + 2 * margin

            ZStack {
                // 木紋外框
                RoundedRectangle(cornerRadius: cellSize * 0.18)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.78, green: 0.55, blue: 0.32),
                                     Color(red: 0.62, green: 0.40, blue: 0.22)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: frameWidth, height: frameHeight)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)

                // 棋面（淺木色）
                RoundedRectangle(cornerRadius: cellSize * 0.08)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.96, green: 0.86, blue: 0.69),
                                     Color(red: 0.90, green: 0.76, blue: 0.55)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: boardWidth + cellSize * 0.3,
                           height: boardHeight + cellSize * 0.3)
                    .overlay(
                        RoundedRectangle(cornerRadius: cellSize * 0.08)
                            .stroke(Color.black.opacity(0.55), lineWidth: 2)
                            .frame(width: boardWidth + cellSize * 0.3,
                                   height: boardHeight + cellSize * 0.3)
                    )

                // 線條 + 九宮 + 楚河漢界 + 位置標記（坐標系與棋子一致）
                ZStack {
                    BoardGridLines(cellSize: cellSize,
                                   boardWidth: boardWidth,
                                   boardHeight: boardHeight)

                    RiverText(cellSize: cellSize,
                              boardWidth: boardWidth)

                    PositionMarkers(cellSize: cellSize)
                        .stroke(Color.black.opacity(0.75), lineWidth: 1.2)
                        .frame(width: boardWidth, height: boardHeight)

                    // 每一個交點都係可 tap 區，無論有冇棋子
                    ForEach(0..<10, id: \.self) { row in
                        ForEach(0..<9, id: \.self) { column in
                            let position = Position(row: row, column: column)
                            ZStack {
                                Color.clear
                                if let piece = gameManager.board.getPiece(at: position) {
                                    PieceView(
                                        piece: piece,
                                        isSelected: gameManager.selectedPosition == position,
                                        cellSize: cellSize
                                    )
                                }
                            }
                            .frame(width: cellSize, height: cellSize)
                            .contentShape(Rectangle())
                            .position(
                                x: CGFloat(column) * cellSize,
                                y: CGFloat(row) * cellSize
                            )
                            .onTapGesture {
                                gameManager.selectPiece(at: position)
                            }
                        }
                    }
                }
                .frame(width: boardWidth, height: boardHeight)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

// MARK: - 線條

struct BoardGridLines: View {
    let cellSize: CGFloat
    let boardWidth: CGFloat
    let boardHeight: CGFloat

    private let riverTop: CGFloat
    private let riverBottom: CGFloat

    init(cellSize: CGFloat, boardWidth: CGFloat, boardHeight: CGFloat) {
        self.cellSize = cellSize
        self.boardWidth = boardWidth
        self.boardHeight = boardHeight
        self.riverTop = 4 * cellSize
        self.riverBottom = 5 * cellSize
    }

    var body: some View {
        ZStack {
            // 直線：最外兩條跨足全板，中間嗰啲喺楚河漢界處斷開
            Path { path in
                for i in 0..<9 {
                    let x = CGFloat(i) * cellSize
                    if i == 0 || i == 8 {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: boardHeight))
                    } else {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: riverTop))
                        path.move(to: CGPoint(x: x, y: riverBottom))
                        path.addLine(to: CGPoint(x: x, y: boardHeight))
                    }
                }
            }
            .stroke(Color.black.opacity(0.85), lineWidth: 1.2)

            // 橫線：10 條
            Path { path in
                for i in 0..<10 {
                    let y = CGFloat(i) * cellSize
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: boardWidth, y: y))
                }
            }
            .stroke(Color.black.opacity(0.85), lineWidth: 1.2)

            // 邊框（最外圍）加粗
            Rectangle()
                .stroke(Color.black.opacity(0.95), lineWidth: 2.4)
                .frame(width: boardWidth, height: boardHeight)
                .position(x: boardWidth / 2, y: boardHeight / 2)

            // 九宮對角線
            Path { path in
                // 黑方九宮 (rows 0-2, cols 3-5)
                path.move(to: CGPoint(x: 3 * cellSize, y: 0))
                path.addLine(to: CGPoint(x: 5 * cellSize, y: 2 * cellSize))
                path.move(to: CGPoint(x: 5 * cellSize, y: 0))
                path.addLine(to: CGPoint(x: 3 * cellSize, y: 2 * cellSize))

                // 紅方九宮 (rows 7-9, cols 3-5)
                path.move(to: CGPoint(x: 3 * cellSize, y: 7 * cellSize))
                path.addLine(to: CGPoint(x: 5 * cellSize, y: 9 * cellSize))
                path.move(to: CGPoint(x: 5 * cellSize, y: 7 * cellSize))
                path.addLine(to: CGPoint(x: 3 * cellSize, y: 9 * cellSize))
            }
            .stroke(Color.black.opacity(0.85), lineWidth: 1.2)
        }
    }
}

// MARK: - 楚河漢界

struct RiverText: View {
    let cellSize: CGFloat
    let boardWidth: CGFloat

    var body: some View {
        let fontSize = cellSize * 0.7
        let y = cellSize * 4.5

        ZStack {
            Text("楚 河")
                .font(.system(size: fontSize, weight: .regular, design: .serif))
                .foregroundColor(Color.black.opacity(0.55))
                .tracking(cellSize * 0.3)
                .position(x: boardWidth * 0.25, y: y)

            Text("漢 界")
                .font(.system(size: fontSize, weight: .regular, design: .serif))
                .foregroundColor(Color.black.opacity(0.55))
                .tracking(cellSize * 0.3)
                .position(x: boardWidth * 0.75, y: y)
        }
    }
}

// MARK: - 位置標記（炮位、兵位嘅角括號）

struct PositionMarkers: Shape {
    let cellSize: CGFloat

    // 每個位置（row, column）以及要畫嘅四角。true 表示要畫該角
    private var markers: [(row: Int, col: Int, tl: Bool, tr: Bool, bl: Bool, br: Bool)] {
        var result: [(Int, Int, Bool, Bool, Bool, Bool)] = []

        // 炮位（全部四角）
        for (r, c) in [(2, 1), (2, 7), (7, 1), (7, 7)] {
            result.append((r, c, true, true, true, true))
        }

        // 兵卒位（內部四角，最左/最右只畫埋內側）
        for r in [3, 6] {
            for c in [0, 2, 4, 6, 8] {
                let drawLeft = c != 0
                let drawRight = c != 8
                result.append((r, c, drawLeft, drawRight, drawLeft, drawRight))
            }
        }
        return result
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let arm = cellSize * 0.18    // L 嘅腳長
        let gap = cellSize * 0.08    // 同交點之間嘅縫隙

        for m in markers {
            let cx = CGFloat(m.col) * cellSize
            let cy = CGFloat(m.row) * cellSize

            if m.tl {
                path.move(to: CGPoint(x: cx - gap - arm, y: cy - gap))
                path.addLine(to: CGPoint(x: cx - gap, y: cy - gap))
                path.addLine(to: CGPoint(x: cx - gap, y: cy - gap - arm))
            }
            if m.tr {
                path.move(to: CGPoint(x: cx + gap + arm, y: cy - gap))
                path.addLine(to: CGPoint(x: cx + gap, y: cy - gap))
                path.addLine(to: CGPoint(x: cx + gap, y: cy - gap - arm))
            }
            if m.bl {
                path.move(to: CGPoint(x: cx - gap - arm, y: cy + gap))
                path.addLine(to: CGPoint(x: cx - gap, y: cy + gap))
                path.addLine(to: CGPoint(x: cx - gap, y: cy + gap + arm))
            }
            if m.br {
                path.move(to: CGPoint(x: cx + gap + arm, y: cy + gap))
                path.addLine(to: CGPoint(x: cx + gap, y: cy + gap))
                path.addLine(to: CGPoint(x: cx + gap, y: cy + gap + arm))
            }
        }
        return path
    }
}

// MARK: - 棋子

struct PieceView: View {
    let piece: Piece
    let isSelected: Bool
    let cellSize: CGFloat

    var body: some View {
        let outer = cellSize * 0.82
        let inner = cellSize * 0.66
        let pieceColor: Color = piece.color == .red ? Color(red: 0.78, green: 0.10, blue: 0.10) : Color.black

        ZStack {
            // 選中時嘅黃色光環
            if isSelected {
                Circle()
                    .fill(Color.yellow.opacity(0.55))
                    .frame(width: outer + cellSize * 0.18, height: outer + cellSize * 0.18)
                    .blur(radius: 4)
            }

            // 外圈：象牙色木質感
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1.00, green: 0.96, blue: 0.86),
                                 Color(red: 0.86, green: 0.74, blue: 0.55)],
                        center: .init(x: 0.35, y: 0.30),
                        startRadius: 0,
                        endRadius: outer * 0.7
                    )
                )
                .frame(width: outer, height: outer)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 1, y: 2)

            // 外圈外緣描線
            Circle()
                .stroke(Color.black.opacity(0.5), lineWidth: 0.8)
                .frame(width: outer, height: outer)

            // 內圈描線（選中時用金色加粗）
            Circle()
                .stroke(isSelected ? Color.orange : pieceColor, lineWidth: isSelected ? 2.5 : 1.5)
                .frame(width: inner, height: inner)

            // 文字
            Text(piece.name)
                .font(.system(size: cellSize * 0.46, weight: .black, design: .serif))
                .foregroundColor(pieceColor)
        }
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
