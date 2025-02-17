//  CRAVEApp/Core/Presentation/Views/Craving/DateView/DateListView.swift

import SwiftUI
import SwiftData

struct DateListView: View {
    @Environment(DependencyContainer.self) private var container
    @StateObject private var viewModel: DateListViewModel

    init(viewModel: DateListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                if viewModel.cravings.isEmpty {
                    Text("No cravings logged yet.")
                      .font(.body)
                      .foregroundColor(.secondary)
                      .padding()
                } else {
                    ForEach(viewModel.groupedCravings.keys.sorted(), id: \.self) { dateString in
                        Section(header: Text(dateString).font(.headline)) {
                            ForEach(viewModel.groupedCravings[dateString]??) { craving in
                                CravingRow(craving: craving)
                            }
                        }
                    }
                }
            }
          .navigationTitle("Cravings by Date")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
                ToolbarItem(placement:.principal) {
                    Text("Cravings by Date")
                      .font(.headline)
                      .foregroundColor(.primary)
                }
            }
          .task {
                viewModel.loadCravings()
            }
        }
    }
}

struct CravingRow: View {
    let craving: CravingEntity

    var body: some View {
        VStack(alignment:.leading) {
            Text(craving.text)
              .font(.headline)
            Text(craving.timestamp, style:.relative)
              .font(.caption)
              .foregroundColor(.secondary)
        }
    }
}
