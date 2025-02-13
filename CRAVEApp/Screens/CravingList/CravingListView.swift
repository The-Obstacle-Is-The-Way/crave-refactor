// CravingListView.swift

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) private var context

    @State private var cravings: [Craving]
    let selectedDate: Date

    init(selectedDate: Date, cravings: [Craving]) {
        self.selectedDate = selectedDate
        self._cravings = State(initialValue: cravings)
    }

    var body: some View {
        List {
            ForEach(cravings, id: \.id) { craving in
                Text(craving.text)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    // Soft-delete the craving
                    let craving = cravings[index]
                    craving.isArchived = true
                    try? context.save()
                }
                
                // Update local cravings array immediately
                cravings.remove(atOffsets: indexSet)
            }
        }
        .navigationTitle(Text(selectedDate, style: .date))
        .toolbar {
            EditButton() // Allows swipe or tap "Edit" to delete
        }
    }
}
