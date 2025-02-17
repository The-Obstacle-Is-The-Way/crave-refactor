
//  CRAVEApp/Core/Domain/Models/DTOs/CravingDTO.swift

import Foundation

struct CravingDTO {
    let id: UUID
    let text: String
    let timestamp: Date
    let isArchived: Bool
}
