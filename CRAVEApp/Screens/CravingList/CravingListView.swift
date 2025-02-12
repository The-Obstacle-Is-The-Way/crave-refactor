//
//  CravingListView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25
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
                    context.delete(cravings[index])  // remove from SwiftData
                }
                do {
                    try context.save()  // persist the deletion
                } catch {
                    print("Delete error: \(error)")
                }
            }
        }
        .navigationTitle(Text(selectedDate, style: .date))
        .toolbar {
            EditButton()
        }
    }
}
