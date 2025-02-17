//  CRAVEApp/Core/Domain/Models/Entities/CravingEntity.swift

import Foundation

// Defines the structure of a craving within our app's core logic.
struct CravingEntity {
    let id: UUID
    let text: String
    let timestamp: Date
    let isArchived: Bool
}
