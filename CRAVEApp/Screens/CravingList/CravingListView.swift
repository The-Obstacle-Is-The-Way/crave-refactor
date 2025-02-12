//
//  DateListView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
//


import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) private var context
    let selectedDate: Date
    @State private var cravings: [Craving]  // Changed to @State
    
    // Initialize with passed cravings array
    init(selectedDate: Date, cravings: [Craving]) {
        self.selectedDate = selectedDate
        _cravings = State(initialValue: cravings)  // Proper @State initialization
    }

    var body: some View {
        List {
            ForEach(cravings, id: \.id) { craving in
                Text(craving.text)
            }
            .onDelete { indexSet in
                withAnimation {
                    // Convert indexSet to array and sort in reverse to safely remove items
                    for index in indexSet.sorted().reversed() {
                        let craving = cravings[index]
                        context.delete(craving)
                        cravings.remove(at: index)
                    }
                    do {
                        try context.save()
                    } catch {
                        print("Delete error: \(error)")
                    }
                }
            }
        }
        .navigationTitle(Text(selectedDate, style: .date))
        .toolbar {
            EditButton()
        }
    }
}
