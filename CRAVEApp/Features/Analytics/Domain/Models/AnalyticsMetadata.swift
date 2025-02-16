//
//  AnalyticsMetadata.swift
//  CRAVEApp
//
//  Purpose: Stores craving analytics metadata.
//

 import Foundation
 import SwiftData

 @Model
 final class AnalyticsMetadata {
     @Attribute(.unique) var id: UUID
     var cravingId: UUID  //  The ID of the CravingModel this metadata belongs to.

     var timestamp: Date
     var interactionCount: Int
     var lastProcessed: Date

     @Attribute(.externalStorage) // Good practice for potentially large arrays
     var userActions: [UserAction]

     // NO @Relationship here.  This is a simple property.

     init(cravingId: UUID) {
         self.id = UUID()
         self.cravingId = cravingId
         self.timestamp = Date()
         self.interactionCount = 0
         self.lastProcessed = Date()
         self.userActions = []
     }

     struct UserAction: Codable {
         let timestamp: Date
         let actionType: String
         let metadata: [String: String]
     }
 }
