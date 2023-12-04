//
//  Item.swift
//  caly
//
//  Created by Cristian Cretu on 04.12.2023.
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
