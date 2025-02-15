//
// 🍒
// CRAVEApp/Screens/DateList/DateListView.swift
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
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(viewModel.groupedCravings.keys.sorted(), id: \.self) { date in
                        Section(header: Text(date).font(.headline)) {
                            ForEach(viewModel.groupedCravings[date] ?? []) { craving in
                                VStack(alignment: .leading) {
                                    Text(craving.cravingText)
                                        .font(.headline)
                                    Text(craving.timestamp, style: .time)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cravings by Date")
            .task { // Use .task for async loading
                viewModel.loadCravings(modelContext: modelContext) // Pass the modelContext
            }
        }
    }
}
