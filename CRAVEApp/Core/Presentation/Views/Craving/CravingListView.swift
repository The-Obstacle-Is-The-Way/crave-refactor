// Core/Presentation/Views/Craving/CravingListView.swift
import SwiftUI

public struct CravingListView: View {
    @ObservedObject private var viewModel: CravingListViewModel
    
    public init(viewModel: CravingListViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else {
                content
            }
        }
        .task {
            await viewModel.loadCravings()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
    }
    
    private var content: some View {
        List {
            ForEach(viewModel.cravings) { craving in
                CravingCard(craving: craving)
                    .swipeActions {
                        Button(role: .destructive) {
                            Task {
                                await viewModel.archiveCraving(craving)
                            }
                        } label: {
                            Label("Archive", systemImage: "archivebox")
                        }
                    }
            }
        }
    }
}
