//
//  CravingListView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
//

import UIKit
import SwiftUI
import SwiftData
import Foundation

struct CravingListView: View {
    @Environment(\.modelContext) private var context
    let selectedDate: Date
    let cravings: [Craving]

    var body: some View {
        List {
            ForEach(cravings, id: \.id) { craving in
                Text(craving.text)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    context.delete(cravings[index])  // ✅ Removes craving from SwiftData
                }
                try? context.save()  // ✅ Saves changes
            }
        }
        // Display the selected date at the top
        .navigationTitle(Text(selectedDate, style: .date))
        .toolbar {
            EditButton()  // ✅ Allows users to delete cravings
        }
    }
}
