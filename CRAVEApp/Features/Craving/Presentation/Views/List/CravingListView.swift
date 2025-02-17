//
//
//  🍒
//  CRAVEApp/Features/Craving/Presentation/Views/List/CravingListView.swift
//  Purpose: Shows a list of all your cravings
//
//

import SwiftUI
import SwiftData

struct CravingListView: View {
    // Get our database connection from SwiftUI
    @Environment(\.modelContext) var modelContext: ModelContext 
    
    // Create our view's brain (ViewModel) that manages all the data
    // @StateObject means "keep this alive as long as our view is alive"
    @StateObject private var viewModel = CravingListViewModel()

    var body: some View {
        // NavigationView lets us have a nice header and navigation capabilities
        NavigationView {
            // Create a list that shows all our cravings
            List {
                // For each craving in our data, create a row
                ForEach(viewModel.cravings) { craving in
                    VStack(alignment: .leading) {
                        // Show the craving text
                        Text(craving.cravingText)
                            .font(CRAVEDesignSystem.Typography.body) 

                        // Show when it was created, in a relative format (like "2 hours ago")
                        Text(craving.timestamp.toRelativeString())
                            .foregroundColor(CRAVEDesignSystem.Colors.textSecondary)
                            .font(CRAVEDesignSystem.Typography.caption1)
                    }
                    // Add swipe actions to each row
                    .swipeActions {
                        // Archive button (swipe right)
                        Button(role: .destructive) {
                            Task {
                                await viewModel.archiveCraving(craving, modelContext: modelContext)
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }

                        // Delete button (swipe right)
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
            // Set up the navigation title
            .navigationTitle("Cravings")
            .navigationBarTitleDisplayMode(.inline)
            // Add the title to the navigation bar
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Cravings")
                        .font(CRAVEDesignSystem.Typography.headline)
                        .foregroundColor(CRAVEDesignSystem.Colors.textPrimary)
                }
            }
            // When the view appears, load our data
            .task {
                await viewModel.loadData(modelContext: modelContext)
            }
        }
    }
}
