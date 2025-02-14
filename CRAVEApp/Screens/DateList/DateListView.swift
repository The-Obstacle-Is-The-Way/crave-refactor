//
//  DateListView.swift
//  CRAVE
//

import SwiftUI
import SwiftData

struct DateListView: View {
    @StateObject private var viewModel: DateListViewModel

    init(viewModel: DateListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel) // ✅ Ensures proper initialization
    }

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
            .onAppear {
                viewModel.loadCravings() // ✅ Fetch cravings when view appears
            }
        }
    }
}

// ✅ Preview with sample data
struct DateListView_Previews: PreviewProvider {
    static var previews: some View {
        DateListView(viewModel: DateListViewModel())
            .modelContainer(for: CravingModel.self, inMemory: true)
    }
}
