//  CRAVEApp/Core/Presentation/Views/Craving/List/CravingListView.swift

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(DependencyContainer.self) private var container
    @StateObject private var viewModel: CravingListViewModel

    init(viewModel: CravingListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cravings) { craving in
                    VStack(alignment:.leading) {
                        Text(craving.text)
                          .font(.body)
                        Text(craving.timestamp, style:.relative)
                          .foregroundColor(.secondary)
                          .font(.caption)
                    }
                  .swipeActions {
                        Button(role:.destructive) {
                            Task {
                                await viewModel.archiveCraving(craving)
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }

                        Button(role:.destructive) {
                            Task {
                                await viewModel.deleteCraving(craving)
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
                ToolbarItem(placement:.principal) {
                    Text("Cravings")
                      .font(.headline)
                      .foregroundColor(.primary)
                }
            }
          .task {
                await viewModel.loadData()
            }
        }
    }
}
