//
//  CravingListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

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
                    // Hard-delete or soft-delete as you prefer:
                    // For full removal:
                    context.delete(cravings[index])
                    // For a soft-delete instead:
                    // cravings[index].isDeleted = true

                    try? context.save()
                }
            }
        }
        .navigationTitle(Text(selectedDate, style: .date))
        .toolbar {
            EditButton() // allows swipe or tap "Edit" to delete
        }
    }
}
