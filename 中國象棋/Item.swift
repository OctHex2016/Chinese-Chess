//
//  Item.swift
//  中國象棋
//
//  Created by Hillman Tam  on 9/5/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
