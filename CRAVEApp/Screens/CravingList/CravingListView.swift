//
//  🍒
//  CRAVEApp/Screens/CravingList/CravingListView.swift
//
//

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CravingListViewModel()

    var body: some View {
        NavigationView { // Keep this NavigationView
            List {
                ForEach(viewModel.cravings) { craving in
                    VStack(alignment: .leading) {
                        Text(craving.cravingText)
                            .font(.headline)
                        Text(craving.timestamp, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.archiveCraving(craving, modelContext: modelContext) // Pass context
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox") // Corrected the image name
                        }
                        
                        Button(role: .destructive) { //Added delete button
                            Task {
                                await viewModel.deleteCraving(craving, modelContext: modelContext)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle("Cravings")
            .task { // Use .task for async loading
                await viewModel.loadData(modelContext: modelContext) // Pass context
            }
        }
    }
}
