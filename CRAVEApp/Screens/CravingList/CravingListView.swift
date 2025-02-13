// CravingListView.swift
// Shows cravings for a particular date, with the ability to swipe-to-delete.

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
                    // Soft-delete: hide from UI but not truly removed
                    cravings[index].isDeleted = true
                }
                try? context.save()
            }
        }
        .navigationTitle(Text(selectedDate, style: .date))
        .toolbar {
            EditButton()
        }
    }
}
