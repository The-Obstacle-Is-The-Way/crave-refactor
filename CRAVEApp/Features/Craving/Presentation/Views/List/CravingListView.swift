//
//
//  🍒
//  CRAVEApp/Features/Craving/Views/List/CravingListView.swift
//  Purpose: A view that displays a list of cravings.
//
//

import SwiftUI
import SwiftData

struct CravingListView: View {
    @Environment(\.modelContext) var modelContext: ModelContext // Removed private
    @StateObject private var viewModel = CravingListViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.cravings) { craving in
                    VStack(alignment: .leading) {
                        Text(craving.cravingText)
                            .font(CRAVEDesignSystem.Typography.body) // UPDATE: Use bodyFont
                        //CHANGE HERE
                        Text(craving.timestamp.toRelativeString()) // Use relative date formatting
                            .foregroundColor(CRAVEDesignSystem.Colors.textSecondary) //UPDATE: secondary text
                            .font(CRAVEDesignSystem.Typography.caption1) //UPDATE: caption
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
            //UPDATE: Use the new title font
            .navigationBarTitleDisplayMode(.inline)
              .toolbar {
                  ToolbarItem(placement: .principal) {
                      Text("Cravings")
                          .font(CRAVEDesignSystem.Typography.headline)
                          .foregroundColor(CRAVEDesignSystem.Colors.textPrimary)
                  }
              }
            .task {
                await viewModel.loadData(modelContext: modelContext)
            }
        }
    }
}
