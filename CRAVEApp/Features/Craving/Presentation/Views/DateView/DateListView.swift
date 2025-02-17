//
//
//  🍒
//  CRAVEApp/Features/Craving/Views/DateView/DateListView.swift
//  Purpose: Displays a list of cravings grouped by date.
//
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = DateListViewModel()

    var body: some View {
        NavigationView {
            List {
                if viewModel.cravings.isEmpty {
                    Text("No cravings logged yet.")
                        .font(.body) // Use .body, not .bodyFont
                        .foregroundColor(.secondary) // Use .secondary
                        .padding()
                } else {
                    ForEach(viewModel.groupedCravings.keys.sorted(), id: \.self) { dateString in
                        Section(header: Text(dateString).font(.headline)) {
                            ForEach(viewModel.groupedCravings[dateString] ?? []) { craving in
                                CravingRow(craving: craving) // Extract to a separate view
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cravings by Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cravings by Date")
                        .font(.headline) // Use .headline, not a custom one here if possible
                        .foregroundColor(.primary) // Use .primary for standard text color
                }
            }
            .task { // Use .task for async loading
                viewModel.loadCravings(modelContext: modelContext) // Pass the modelContext
            }
        }
    }
}

// Extracted for clarity and to simplify the main view.
struct CravingRow: View {
    let craving: CravingModel

    var body: some View {
        VStack(alignment: .leading) {
            Text(craving.cravingText)
                .font(.headline)
            Text(craving.timestamp, style: .relative) // Use built-in relative style
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
