//
//  CravingListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CravingListViewModel() // ✅ Use StateObject to manage ViewModel

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cravings) { craving in // ✅ Iterate through viewModel's cravings
                    VStack(alignment: .leading) {
                        Text(craving.cravingText)
                            .font(.headline)
                        Text(craving.timestamp, style: .date)
                            .foregroundColor(.secondary)
                    }
                    .swipeActions { // ✅ Swipe action for archiving
                        Button(role: .destructive) {
                            Task { // ✅ Use Task for async operation
                                await viewModel.archiveCraving(craving)
                            }
                        } label: {
                            Label("Archive", systemImage: "archive")
                        }
                    }
                }
            }
            .navigationTitle("Cravings")
            .refreshable { // ✅ Pull-to-refresh
                await viewModel.refreshData()
            }
            .task { // ✅ Load initial data onAppear-like behavior
                await viewModel.loadInitialData()
            }
        }
        .onAppear {
            viewModel.setModelContext(modelContext) // ✅ Ensure ModelContext is set on appear
        }
    }
}

#Preview {
    CravingListView()
        .modelContainer(for: CravingModel.self, inMemory: true)
}
