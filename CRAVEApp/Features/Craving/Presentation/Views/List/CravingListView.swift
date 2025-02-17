//
//
//  🍒
//  CRAVEApp/Features/Craving/Presentation/Views/List/CravingListView.swift
//  Purpose: Shows a list of all your cravings
//
//

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) var modelContext: ModelContext
    @StateObject private var viewModel = CravingListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cravings) { craving in
                    VStack(alignment: .leading) {
                        Text(craving.cravingText)
                            .font(.body)
                        Text(craving.timestamp, style: .relative)
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.archiveCraving(craving, modelContext: modelContext)
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }

                        Button(role: .destructive) {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cravings")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
            }
            .task {
                await viewModel.loadData(modelContext: modelContext)
            }
        }
    }
}
