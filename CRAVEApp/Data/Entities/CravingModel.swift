//
//  CravingModel.swift
//  CRAVE
//

import Foundation
import SwiftData

@Model public final class CravingModel {
    public var timestamp: Date
    public var notes: String?
    
    public init(timestamp: Date = Date(), notes: String? = nil) {
        self.timestamp = timestamp
        self.notes = notes
    }
}
