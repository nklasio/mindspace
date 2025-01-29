//
//  Item.swift
//  MindScape
//
//  Created by Niklas Stambor on 29.01.25.
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
