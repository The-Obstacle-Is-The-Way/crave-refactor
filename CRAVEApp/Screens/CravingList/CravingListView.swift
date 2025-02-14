//
//  CravingListView.swift
//  CRAVE
//


import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) private var modelContext
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
        }
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}
