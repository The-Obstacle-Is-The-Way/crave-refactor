// CRAVEApp/Screens/CravingList/CravingListAnalytics.swift

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: CravingListViewModel  // Declare, not initialize

    init() {
        _viewModel = StateObject(wrappedValue: CravingListViewModel()) // Initialize in init
    }

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
                                await viewModel.archiveCraving(craving)
                            }
                        } label: {
                            Label("Archive", systemImage: "archive")
                        }
                    }
                }
            }
            .navigationTitle("Cravings")
            .refreshable {
                await viewModel.refreshData()
            }
           // .task { // Removed .task
            //    await viewModel.loadInitialData()
           // }
        }
        .onAppear {
            viewModel.setModelContext(modelContext) // Set context here
        }
    }
}

