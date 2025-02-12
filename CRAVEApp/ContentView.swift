//
//  ContentView.swift
//  CRAVE
//
//  Created by John H Jung on 2/12/25.
//

import UIKit
import SwiftUI
import Foundation
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(sort: \Craving.timestamp, order: .reverse)
    private var cravings: [Craving]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(cravings) { craving in
                    NavigationLink {
                        Text("Craving logged at \(craving.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                            .padding()
                    } label: {
                        VStack(alignment: .leading) {
                            Text(craving.text)
                                .font(.headline)
                            Text(craving.timestamp, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteCravings)
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                #endif
                
                ToolbarItem {
                    Button(action: addCraving) {
                        Label("Add Craving", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select a Craving")
        }
    }

    private func addCraving() {
        withAnimation {
            CravingManager.shared.addCraving("New Craving from ContentView", using: modelContext)
        }
    }

    private func deleteCravings(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let craving = cravings[index]
                CravingManager.shared.softDeleteCraving(craving, using: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Craving.self, inMemory: true)
}
