//
//  🍒
//  CRAVEApp/Screens/CravingList/CravingListView.swift
//
//

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) var modelContext // Removed private
    @StateObject private var viewModel = CravingListViewModel()

    var body: some View {
        NavigationView {
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
            .task {
                await viewModel.loadData(modelContext: modelContext)
            }
        }
    }
}
